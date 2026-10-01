/**
 * Pipeline Approve — /approve: утверждение плана и переход в IMPL.
 *
 * Читает docs/tasks/<slug>/plan.md, парсит задачи (id/title/depends_on/validation),
 * показывает сводку и спрашивает подтверждение (ctx.ui.confirm, без таймаута —
 * решение за человеком). Да → APPROVE→IMPL; Нет → обратно PLAN.
 * Headless (нет UI): отказ — /approve требует интерактивного подтверждения.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "fs";
import { join } from "path";
import type { PipelineStore } from "./state.ts";

export interface PlanTask {
	id: string;
	title: string;
	dependsOn: string[];
	validation: string;
}

/** Простой парсер задач из plan.md (формат из prompts/plan.md). */
export function parsePlan(planMd: string): PlanTask[] {
	const tasks: PlanTask[] = [];
	let cur: Partial<PlanTask> | null = null;
	for (const rawLine of planMd.split("\n")) {
		const line = rawLine.trim();
		if (/^-\s+id:\s*(\S+)/.test(line)) {
			if (cur?.id) tasks.push(cur as PlanTask);
			cur = { id: RegExp.$1, title: "", dependsOn: [], validation: "" };
			continue;
		}
		if (!cur) continue;
		let m = line.match(/^title:\s*(.+)$/);
		if (m) {
			cur.title = m[1].trim();
			continue;
		}
		m = line.match(/^depends_on:\s*\[(.*)\]$/);
		if (m) {
			cur.dependsOn = m[1].split(",").map((s) => s.trim().replace(/^['"]|['"]$/g, "")).filter(Boolean);
			continue;
		}
		m = line.match(/^validation:\s*(.+)$/);
		if (m) cur.validation = m[1].trim();
	}
	if (cur?.id) tasks.push(cur as PlanTask);
	return tasks;
}

export function registerApproveCommand(pi: ExtensionAPI, store: PipelineStore, updateFooter: (stage: string, slug: string | undefined, ctx: { ui: { setStatus(key: string, text: string | undefined): void } }) => void) {
	pi.registerCommand("approve", {
		description: "Утвердить план задачи (PLAN → IMPL) после подтверждения",
		handler: async (_args, ctx) => {
			const current = store.get();
			const slug = current.slug;
			if (!slug) {
				ctx.ui.notify("Нет активной задачи: /task <slug>", "error");
				return;
			}
			if (current.stage !== "PLAN" && current.stage !== "APPROVE") {
				ctx.ui.notify(`/approve работает на стадии PLAN (сейчас ${current.stage})`, "error");
				return;
			}

			let planMd: string;
			try {
				planMd = readFileSync(join(ctx.cwd, "docs", "tasks", slug, "plan.md"), "utf8");
			} catch {
				ctx.ui.notify(`Не найден docs/tasks/${slug}/plan.md — сначала /plan`, "error");
				return;
			}

			const tasks = parsePlan(planMd);
			if (tasks.length === 0) {
				ctx.ui.notify(`В docs/tasks/${slug}/plan.md не найдено задач (формат: "- id: task-01 ...")`, "error");
				return;
			}

			if (!ctx.hasUI) {
				ctx.ui.notify(
					`/approve требует интерактивного подтверждения (UI). Headless: /stage set IMPL --force`,
					"error",
				);
				return;
			}

			store.set({ stage: "APPROVE", slug }, ctx.cwd);
			updateFooter("APPROVE", slug, ctx);

			const summary =
				`Задача ${slug}: ${tasks.length} шаг(ов)\n\n` +
				tasks.map((t) => `• ${t.id}: ${t.title}${t.dependsOn.length ? ` (после ${t.dependsOn.join(",")})` : ""}`).join("\n") +
				"\n\nУтвердить план и перейти к IMPL?";

			const ok = await ctx.ui.confirm("Утверждение плана", summary);
			if (ok) {
				store.set({ stage: "IMPL", slug }, ctx.cwd);
				updateFooter("IMPL", slug, ctx);
				ctx.ui.notify(`План утверждён. Стадия: IMPL. Дальше: /impl`, "success");
			} else {
				store.set({ stage: "PLAN", slug }, ctx.cwd);
				updateFooter("PLAN", slug, ctx);
				ctx.ui.notify("Отказ: возврат к PLAN (правки плана — /plan)", "warning");
			}
		},
	});
}
