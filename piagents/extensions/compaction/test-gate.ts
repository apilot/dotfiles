/**
 * Test Gate — ход не завершается на стадии TEST, пока validation-команды активной
 * задачи не зелёные (или не исчерпан лимит попыток → доклад человеку).
 *
 * Механика: agent_before_settle (финальная actionable граница) → если стадия TEST
 * и агент завершился «успешно» → прогоняем все validation из docs/tasks/<slug>/plan.md
 * → при падении добавляем custom_message с перечнем и continue: true (одна дополнительная
 * итерация модели). Максимум MAX_CONTINUATIONS на один пользовательский запрос,
 * дальше — settle с предупреждением (stop-on-failure, человек решает).
 */

import { readFileSync } from "fs";
import { join } from "path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MAX_CONTINUATIONS = 2;

interface PlanTaskLite {
	id: string;
	validation: string;
}

function parseValidations(planMd: string): PlanTaskLite[] {
	const out: PlanTaskLite[] = [];
	let cur: { id: string; validation: string } | null = null;
	for (const raw of planMd.split("\n")) {
		const line = raw.trim();
		let m = line.match(/^-\s+id:\s*(\S+)/);
		if (m) {
			if (cur?.id) out.push(cur);
			cur = { id: m[1], validation: "" };
			continue;
		}
		if (cur && (m = line.match(/^validation:\s*(.+)$/))) cur.validation = m[1].trim();
	}
	if (cur?.id) out.push(cur);
	return out;
}

function readStage(cwd: string): { stage?: string; slug?: string } | null {
	try {
		return JSON.parse(readFileSync(join(cwd, ".pi", "pipeline.state.json"), "utf8"));
	} catch {
		return null;
	}
}

export default function testGate(pi: ExtensionAPI) {
	let continuations = 0;
	let lastLeafId: string | null = null;

	pi.on("turn_start", (event) => {
		// новый пользовательский запрос — сбрасываем счётчик продолжений
		if (event.turnIndex === 0) continuations = 0;
	});

	pi.on("agent_before_settle", async (event, ctx) => {
		if (event.outcome !== "completed") return undefined; // aborted/error — не мешаем

		const stage = readStage(ctx.cwd);
		if (!stage || stage.stage !== "TEST" || !stage.slug) return undefined;

		// один гейт-прогон на лист сессии (agent_before_settle может зваться повторно)
		const leafId = ctx.sessionManager.getLeafId();
		if (leafId && leafId === lastLeafId && continuations >= MAX_CONTINUATIONS) return undefined;

		let tasks: PlanTaskLite[] = [];
		try {
			tasks = parseValidations(readFileSync(join(ctx.cwd, "docs", "tasks", stage.slug, "plan.md"), "utf8"));
		} catch {
			return undefined; // нет плана — не гейтим
		}
		const withValidation = tasks.filter((t) => t.validation);
		if (withValidation.length === 0) return undefined;

		// прогон всех validation в основной копии
		const failures: string[] = [];
		for (const t of withValidation) {
			const res = await pi
				.exec("bash", ["-c", t.validation], { cwd: ctx.cwd, timeout: 120_000 })
				.catch(() => ({ code: 1, stdout: "", stderr: "exec error" }));
			if (res.code !== 0) {
				const out = (res.stdout + res.stderr).trim().slice(0, 300);
				failures.push(`${t.id}: \`${t.validation}\` → exit ${res.code}${out ? `\n${out}` : ""}`);
			}
		}

		if (failures.length === 0) {
			if (ctx.hasUI) ctx.ui.notify("test-gate: validation зелёные ✓", "success");
			return undefined; // zelёные — settle
		}

		if (continuations >= MAX_CONTINUATIONS) {
			if (ctx.hasUI) {
				ctx.ui.notify(
					`test-gate: validation всё ещё красные после ${MAX_CONTINUATIONS} продолжений — сдаюсь, человек решает:\n${failures.join("\n")}`,
					"error",
				);
			}
			return undefined; // лимит исчерпан — settle (stop-on-failure)
		}

		continuations++;
		lastLeafId = ctx.sessionManager.getLeafId();
		if (ctx.hasUI) ctx.ui.notify(`test-gate: красная validation (${failures.length}) — продолжение ${continuations}/${MAX_CONTINUATIONS}`, "warning");

		return {
			entries: [
				{
					type: "custom_message" as const,
					customType: "test-gate",
					display: true,
					content:
						`[TEST GATE] Ход не завершён: validation активной задачи ${stage.slug} красная.\n\n` +
						failures.map((f) => `✗ ${f}`).join("\n") +
						`\n\nИсправь причину (минимальные правки), прогони validation снова. Не меняй сами validation-команды.`,
				},
			],
			continue: true,
		};
	});
}
