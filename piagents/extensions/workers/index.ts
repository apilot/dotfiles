/**
 * Workers — worker fleet: параллельные субагенты в git worktrees с merge-back.
 *
 * Тулы:
 *  - task_dispatch {slug} — построить граф из docs/tasks/<slug>/plan.md и исполнить:
 *    батчи по уровням зависимостей, параллельность ≤3, воркеры (glm-5.3-flash) в
 *    worktrees .wt/<task-id>, validation → commit → merge → отчёт → очистка.
 *    Сбой/конфликт → стоп, остальные задачи blocked (stop-on-failure).
 *  - task_status — компактная сводка (состояние восстанавливается из сессии).
 *
 * Требует стадию IMPL из .pi/pipeline.state.json (снапшот пайплайна) и чистый main.
 */

import { readFileSync } from "fs";
import { join } from "path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { cleanupWorktree, mergeback, writeTaskReport } from "./mergeback.ts";
import { mapWithConcurrencyLimit, runWorker } from "./spawn.ts";
import { createWorkersState, GraphError, parsePlanTasks, topoBatches, type PlanTask } from "./taskgraph.ts";

const MAX_CONCURRENCY = 3;

/** Читает стадию пайплайна из снапшота (не зависит от расширения pipeline). */
function readPipelineStage(cwd: string): { stage: string; slug?: string } | null {
	try {
		return JSON.parse(readFileSync(join(cwd, ".pi", "pipeline.state.json"), "utf8"));
	} catch {
		return null;
	}
}

export default function (pi: ExtensionAPI) {
	const workers = createWorkersState(pi);

	pi.on("session_start", async (_event, ctx) => {
		workers.restore(ctx.sessionManager.getBranch() as never);
	});

	const DispatchParams = Type.Object({
		slug: Type.Optional(Type.String({ description: "slug задачи (docs/tasks/<slug>); по умолчанию — активная" })),
		dryRun: Type.Optional(Type.Boolean({ description: "только построить граф и показать батчи" })),
	});

	pi.registerTool({
		name: "task_dispatch",
		label: "Dispatch workers",
		description:
			"Исполнить план docs/tasks/<slug>/plan.md воркерами: граф зависимостей → параллельные батчи (git worktrees), validation, merge-back, отчёты. Требует стадию IMPL. Сбой → стоп.",
		parameters: DispatchParams,

		async execute(_toolCallId, params, signal, onUpdate, ctx) {
			const report = (text: string) => onUpdate?.({ content: [{ type: "text", text }], details: undefined as never });

			// --- валидация предусловий -------------------------------------------
			const stage = readPipelineStage(ctx.cwd);
			const slug = params.slug ?? stage?.slug;
			if (!slug) return err("Не указан slug (нет активной задачи в pipeline.state.json).");
			if (!stage || stage.stage !== "IMPL") {
				return err(`Стадия ${stage?.stage ?? "неизвестна"}: dispatch требует IMPL (/approve).`);
			}

			const planPath = join(ctx.cwd, "docs", "tasks", slug, "plan.md");
			let planMd: string;
			try {
				planMd = readFileSync(planPath, "utf8");
			} catch {
				return err(`Не найден ${planPath}`);
			}

			const tasks = parsePlanTasks(planMd);
			if (tasks.length === 0) return err("В plan.md нет задач в формате '- id: task-NN ...'");

			let batches: PlanTask[][];
			try {
				batches = topoBatches(tasks);
			} catch (e) {
				return err(`Граф зависимостей некорректен: ${(e as GraphError).message}`);
			}

			const batchesText = batches.map((b, i) => `батч ${i + 1}: ${b.map((t) => t.id).join(" ∥ ")}`).join("; ");
			if (params.dryRun) {
				return ok(`Граф (${tasks.length} задач): ${batchesText}. Запуск: task_dispatch без dryRun.`);
			}

			// чистый main обязателен (merge в него)
			const status = await pi.exec("git", ["status", "--porcelain"], { cwd: ctx.cwd });
			const dirty = status.stdout.split("\n").filter((l) => l.trim() && !l.trim().startsWith("??"));
			if (dirty.length > 0) {
				return err(`Основная ветка грязная (${dirty.length} изменённых файлов) — закоммить перед dispatch.`);
			}

			// чекпойнт: stash-снапшот текущего состояния (без изменения worktree)
			const cp = await pi.exec("git", ["stash", "create"], { cwd: ctx.cwd });
			pi.appendEntry("workers-checkpoint", { slug, ref: cp.stdout.trim() || null, ts: new Date().toISOString() });

			workers.init(slug, tasks);
			report(`Граф: ${batchesText}`);

			// --- исполнение по батчам --------------------------------------------
			outer: for (const batch of batches) {
				report(`Батч: ${batch.map((t) => t.id).join(", ")} (≤${MAX_CONCURRENCY} параллельно)`);

				await mapWithConcurrencyLimit(batch, MAX_CONCURRENCY, async (task) => {
					const branch = task.id;
					const worktree = join(ctx.cwd, ".wt", task.id);
					workers.update(task.id, { status: "running", branch, worktree, startedAt: new Date().toISOString() });
					report(`${task.id}: worktree + воркер…`);

					// идемпотентность: зачищаем остатки прошлых прогонов
					await pi.exec("git", ["worktree", "prune"], { cwd: ctx.cwd });
					await pi.exec("git", ["worktree", "remove", "--force", worktree], { cwd: ctx.cwd }).catch(() => {});
					await pi.exec("git", ["branch", "-D", branch], { cwd: ctx.cwd }).catch(() => {});

					const wtAdd = await pi.exec("git", ["worktree", "add", worktree, "-b", branch], { cwd: ctx.cwd });
					if (wtAdd.code !== 0) {
						workers.update(task.id, { status: "failed", reason: `git worktree add: ${wtAdd.stderr.slice(0, 200)}`, finishedAt: new Date().toISOString() });
						return;
					}

					// воркер
					const worker = await runWorker({ slug, task, worktree, signal });

					// mergeback
					const outcome = await mergeback({ pi, exec: pi.exec.bind(pi), mainCwd: ctx.cwd, slug, task, worktree, branch, worker });
					const state = workers.tasks.find((s) => s.id === task.id)!;
					workers.update(task.id, {
						status: outcome.status,
						reason: outcome.reason,
						summary: worker.output.slice(0, 300),
						finishedAt: new Date().toISOString(),
					});

					// отчёт всегда (и на провал тоже)
					try {
						await writeTaskReport({ cwd: ctx.cwd, slug, task, state: { ...state, ...outcome }, worker, outcome });
					} catch {
						/* отчёт не критичен */
					}

					// очистка: worktree всегда; ветка — если не конфликт
					try {
						await cleanupWorktree(pi.exec.bind(pi), ctx.cwd, worktree, branch, outcome.status === "conflict");
					} catch {
						/* мусор в .wt/ приберётся вручную */
					}
				});

				// stop-on-failure: провал/конфликт в батче останавливает всё
				const bad = workers.tasks.filter((t) => t.status === "failed" || t.status === "conflict");
				if (bad.length > 0) {
					workers.blockRemaining(`остановлено после сбоя: ${bad.map((t) => t.id).join(", ")}`);
					break outer;
				}
			}

			const summary = workers.compact();
			const hasFail = workers.tasks.some((t) => t.status === "failed" || t.status === "conflict");
			return {
				content: [
					{
						type: "text",
						text:
							(hasFail ? "⚠️ Есть сбои (stop-on-failure, перезапуска автоматически НЕТ):\n" : "✅ Все задачи завершены:\n") +
							summary +
							`\nОтчёты: docs/tasks/${slug}/reports/`,
					},
				],
				details: { slug, tasks: workers.tasks },
				isError: hasFail,
			};
		},
	});

	pi.registerTool({
		name: "task_status",
		label: "Workers status",
		description: "Компактная сводка статусов воркеров последнего dispatch (MVI).",
		parameters: Type.Object({}),

		async execute() {
			return {
				content: [{ type: "text", text: workers.compact() }],
				details: { slug: workers.slug, tasks: workers.tasks },
			};
		},
	});
}

function err(text: string) {
	return { content: [{ type: "text", text: `dispatch: ${text}` }], details: undefined, isError: true };
}
function ok(text: string) {
	return { content: [{ type: "text", text }], details: undefined };
}
