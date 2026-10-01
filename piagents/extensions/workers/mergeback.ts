/**
 * Mergeback — validation воркера, merge в основную ветку, отчёты, очистка worktree.
 *
 * Порядок: validation в worktree → commit в worktree → merge в main → отчёт в
 * docs/tasks/<slug>/reports/<id>.md → удаление worktree и ветки.
 * Конфликт merge → статус conflict, оркестратор решает (stop-on-failure).
 */

import { withFileMutationQueue, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { mkdir, writeFile } from "fs/promises";
import { dirname, join } from "path";
import type { PlanTask, TaskState } from "./taskgraph.ts";
import type { WorkerResult } from "./spawn.ts";

export interface ExecLike {
	(command: string, args: string[], options?: { cwd?: string; timeout?: number }): Promise<{
		stdout: string;
		stderr: string;
		code: number;
	}>;
}

export interface MergeOutcome {
	status: "done" | "failed" | "conflict";
	reason?: string;
	validationOutput: string;
	commit?: string;
}

/** Прогоняет validation-команду задачи в worktree. */
export async function runValidation(exec: ExecLike, worktree: string, task: PlanTask): Promise<{ ok: boolean; output: string }> {
	if (!task.validation) return { ok: true, output: "(validation не задана)" };
	const res = await exec("bash", ["-c", task.validation], { cwd: worktree, timeout: 180_000 });
	const output = (res.stdout + (res.stderr ? `\n${res.stderr}` : "")).trim().slice(0, 2000);
	return { ok: res.code === 0, output: output || `exit ${res.code}` };
}

/** Commit всех изменений воркера в его ветке (в worktree). */
async function commitWorktree(exec: ExecLike, worktree: string, task: PlanTask): Promise<void> {
	await exec("git", ["add", "-A"], { cwd: worktree });
	const st = await exec("git", ["status", "--porcelain"], { cwd: worktree });
	if (!st.stdout.trim()) return; // нечего коммитить
	await exec("git", ["commit", "-m", `${task.id}: ${task.title}`], { cwd: worktree });
}

/** Полный цикл mergeback для одной задачи. */
export async function mergeback(opts: {
	pi: ExtensionAPI;
	exec: ExecLike;
	mainCwd: string;
	slug: string;
	task: PlanTask;
	worktree: string;
	branch: string;
	worker: WorkerResult;
}): Promise<MergeOutcome> {
	const { pi, exec, mainCwd, slug, task, worktree, branch, worker } = opts;

	// 1. воркер упал?
	if (worker.exitCode !== 0 || /^\s*FAILED/m.test(worker.output)) {
		return { status: "failed", reason: worker.error ?? "воркер отчитался FAILED", validationOutput: worker.output.slice(0, 500) };
	}

	// 2. validation в worktree
	const val = await runValidation(exec, worktree, task);
	if (!val.ok) {
		return { status: "failed", reason: "validation не прошла в worktree", validationOutput: val.output };
	}

	// 3. commit в ветке воркера
	await commitWorktree(exec, worktree, task);

	// 4. merge в основную ветку
	const merge = await exec("git", ["merge", "--no-edit", branch], { cwd: mainCwd });
	if (merge.code !== 0) {
		// откатываем конфликтное состояние merge, ветку сохраняем для разбора
		await exec("git", ["merge", "--abort"], { cwd: mainCwd });
		return { status: "conflict", reason: "конфликт merge (ветка сохранена для разбора)", validationOutput: val.output };
	}

	return {
		status: "done",
		validationOutput: val.output,
		commit: merge.stdout.match(/([0-9a-f]{7,40})/)?.[1],
	};
}

/** Отчёт по задаче → docs/tasks/<slug>/reports/<id>.md. */
export async function writeTaskReport(opts: {
	cwd: string;
	slug: string;
	task: PlanTask;
	state: TaskState;
	worker: WorkerResult;
	outcome: MergeOutcome;
}): Promise<string> {
	const { cwd, slug, task, state, worker, outcome } = opts;
	const file = join(cwd, "docs", "tasks", slug, "reports", `${task.id}.md`);
	const body = [
		`# ${task.id}: ${task.title}`,
		"",
		`- Статус: **${outcome.status}**`,
		`- Ветка: \`${state.branch ?? task.id}\` (worktree: \`${state.worktree ?? "—"}\`)`,
		`- Время: ${state.startedAt ?? "—"} → ${state.finishedAt ?? "—"}`,
		`- Validation: \`${task.validation || "—"}\``,
		`- Файлы задачи: ${task.files.length ? task.files.map((f) => `\`${f}\``).join(", ") : "—"}`,
		outcome.reason ? `- Причина сбоя: ${outcome.reason}` : "",
		"",
		"## Вывод validation",
		"",
		"```",
		outcome.validationOutput || "(пусто)",
		"```",
		"",
		"## Отчёт воркера",
		"",
		worker.output.trim() || "(пусто)",
		"",
	].join("\n");

	await withFileMutationQueue(file, async () => {
		await mkdir(dirname(file), { recursive: true });
		await writeFile(file, body);
	});
	return file;
}

/** Очистка: worktree и ветка (ветка сохраняется при конфликте). */
export async function cleanupWorktree(exec: ExecLike, mainCwd: string, worktree: string, branch: string, keepBranch: boolean): Promise<void> {
	await exec("git", ["worktree", "remove", "--force", worktree], { cwd: mainCwd });
	if (!keepBranch) {
		await exec("git", ["branch", "-D", branch], { cwd: mainCwd });
	}
}
