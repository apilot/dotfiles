/**
 * Best-of-N — N параллельных веток реализации утверждённого плана с выбором лучшей.
 *
 * Дизайн: вместо ветвления session tree (которое делит один worktree и не даёт
 * изолировать правки) — N git-веток bestof/<slug>/<i> от точки утверждения.
 * Каждая попытка: свежая сессия `pi --mode json` (модель/уровень по ротации),
 * полный IMPL-прогон, commit, diff-статистика, validation. Итог — компактная
 * таблица, выбор через ctx.ui.select (TUI) или отчёт в reports/bestof.md (headless).
 *
 * /bestof <N>   — N ≤ 3 (ротация: glm-5.3:high → glm-5.3-flash:high → glm-5-turbo:medium)
 */

import { spawn } from "node:child_process";
import { readFileSync } from "fs";
import { join } from "path";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

interface Attempt {
	index: number;
	branch: string;
	model: string;
	thinking: string;
	files: number;
	insertions: number;
	deletions: number;
	validation: string; // "OK" | "FAIL: ..." | "—"
	summary: string;
}

const ROTATION = [
	{ model: "zai/glm-5.3", thinking: "high" },
	{ model: "zai/glm-5.3-flash", thinking: "high" },
	{ model: "zai/glm-5-turbo", thinking: "medium" },
];

function readStage(cwd: string): { stage?: string; slug?: string } | null {
	try {
		return JSON.parse(readFileSync(join(cwd, ".pi", "pipeline.state.json"), "utf8"));
	} catch {
		return null;
	}
}

function loadImplPrompt(slug: string): string {
	// тот же шаблон, что и /impl
	const raw = readFileSync(new URL("../../prompts/impl.md", import.meta.url), "utf8");
	return raw.replaceAll("{{SLUG}}", slug);
}

/** Прогон одной попытки в основной рабочей копии (последовательно, на своей ветке). */
async function runAttempt(
	pi: ExtensionAPI,
	cwd: string,
	slug: string,
	i: number,
	rotation: { model: string; thinking: string },
	validationCmd: string | undefined,
	baseRef: string,
): Promise<Attempt> {
	const branch = `bestof/${slug}/${i}`;
	const a: Attempt = { index: i, branch, model: rotation.model, thinking: rotation.thinking, files: 0, insertions: 0, deletions: 0, validation: "—", summary: "" };

	await pi.exec("git", ["checkout", "-B", branch], { cwd });

	// свежая сессия-исполнитель
	const args = [
		"--mode", "json", "-p", "--no-session",
		"--model", rotation.model,
		"--thinking", rotation.thinking,
		loadImplPrompt(slug),
	];
	await new Promise<void>((resolve) => {
		const proc = spawn("pi", args, { cwd, stdio: ["ignore", "ignore", "ignore"] });
		proc.on("close", () => resolve());
		proc.on("error", () => resolve());
	});

	// фиксируем изменения попытки
	await pi.exec("git", ["add", "-A"], { cwd });
	const st = await pi.exec("git", ["status", "--porcelain"], { cwd });
	if (st.stdout.trim()) {
		await pi.exec("git", ["commit", "-m", `bestof ${i}: попытка (${rotation.model})`], { cwd });
	}

	// статистика диффа от точки ветвления
	const diff = await pi.exec("git", ["diff", "--numstat", `${baseRef}...${branch}`], { cwd });
	for (const line of diff.stdout.trim().split("\n").filter(Boolean)) {
		const [add, del] = line.split("\t");
		a.insertions += parseInt(add) || 0;
		a.deletions += parseInt(del) || 0;
		a.files += 1;
	}

	// validation
	if (validationCmd) {
		const val = await pi.exec("bash", ["-c", validationCmd], { cwd, timeout: 180_000 });
		a.validation = val.code === 0 ? "OK" : `FAIL(${val.code})`;
	}

	const log = await pi.exec("git", ["log", `${baseRef}..${branch}`, "--oneline"], { cwd });
	a.summary = log.stdout.trim().split("\n").slice(0, 3).join(" | ").slice(0, 200);
	return a;
}

export function registerBestofCommand(pi: ExtensionAPI) {
	pi.registerCommand("bestof", {
		description: "N веток реализации плана (git-изоляция), сравнение, выбор лучшей. /bestof <N≤3>",
		handler: async (args, ctx: ExtensionCommandContext) => {
			const n = Math.min(3, Math.max(2, parseInt(args.trim()) || 2));
			const stage = readStage(ctx.cwd);
			if (!stage?.slug) {
				ctx.ui.notify("Нет активной задачи: /task <slug>", "error");
				return;
			}
			if (stage.stage !== "IMPL") {
				ctx.ui.notify(`/bestof работает на стадии IMPL (сейчас ${stage.stage})`, "error");
				return;
			}
			const planPath = join(ctx.cwd, "docs", "tasks", stage.slug, "plan.md");
			let planMd: string;
			try {
				planMd = readFileSync(planPath, "utf8");
			} catch {
				ctx.ui.notify(`Не найден ${planPath}`, "error");
				return;
			}
			const validationCmd = planMd.match(/^[ \t]*validation:[ \t]*(.+)$/m)?.[1]?.trim();

			// чистая основная ветка обязательна (мы ходим по веткам в этой копии)
			const st = await pi.exec("git", ["status", "--porcelain"], { cwd: ctx.cwd });
			if (st.stdout.trim()) {
				ctx.ui.notify("Рабочая копия грязная — закоммить перед /bestof", "error");
				return;
			}

			// точка ветвления и имя исходной ветки
			const base = await pi.exec("git", ["rev-parse", "--abbrev-ref", "HEAD"], { cwd: ctx.cwd });
			const baseBranch = base.stdout.trim() || "main";
			const baseSha = (await pi.exec("git", ["rev-parse", "HEAD"], { cwd: ctx.cwd })).stdout.trim();

			ctx.ui.notify(`bestof: ${n} попытки на ветках bestof/${stage.slug}/*…`, "info");
			const attempts: Attempt[] = [];
			for (let i = 1; i <= n; i++) {
				ctx.ui.notify(`bestof: попытка ${i}/${n} (${ROTATION[(i - 1) % ROTATION.length].model})`, "info");
				attempts.push(await runAttempt(pi, ctx.cwd, stage.slug, i, ROTATION[(i - 1) % ROTATION.length], validationCmd, baseSha));
				await pi.exec("git", ["checkout", baseBranch], { cwd: ctx.cwd });
			}

			const table = attempts
				.map((a) => `${a.index}. ${a.model}:${a.thinking} | файлов ${a.files} | +${a.insertions}/−${a.deletions} | validation ${a.validation}\n   ${a.summary}`)
				.join("\n");

			// отчёт всегда
			const reportFile = join(ctx.cwd, "docs", "tasks", stage.slug, "reports", "bestof.md");
			const { mkdir, writeFile } = await import("fs/promises");
			const { dirname } = await import("path");
			await mkdir(dirname(reportFile), { recursive: true });
			await writeFile(reportFile, `# Best-of-${n}: ${stage.slug}\n\n\`\`\`\n${table}\n\`\`\`\n\nВетки: ${attempts.map((a) => a.branch).join(", ")}\nПрименить: git merge <ветка>\n`);

			if (!ctx.hasUI) {
				ctx.ui.notify(`bestof: отчёт в ${reportFile}; применить вручную: git merge bestof/${stage.slug}/<N>`, "warning");
				return;
			}

			const choice = await ctx.ui.select(`Best-of-${n}: какую ветку применить?`, [
				...attempts.map((a) => `${a.index}. ${a.model} (+${a.insertions}/−${a.deletions}, validation ${a.validation})`),
				"Ни одна — оставить как было",
			]);
			const picked = attempts[parseInt(choice?.[0] ?? "") - 1];
			if (!picked) {
				ctx.ui.notify("Ничего не применено (ветки сохранены)", "warning");
				return;
			}
			const merge = await pi.exec("git", ["merge", "--no-edit", picked.branch], { cwd: ctx.cwd });
			if (merge.code !== 0) {
				await pi.exec("git", ["merge", "--abort"], { cwd: ctx.cwd });
				ctx.ui.notify(`Конфликт при merge ${picked.branch} — разреши вручную`, "error");
				return;
			}
			// убрать непрошедшие ветки
			for (const a of attempts) {
				if (a.index !== picked.index) await pi.exec("git", ["branch", "-D", a.branch], { cwd: ctx.cwd }).catch(() => {});
			}
			ctx.ui.notify(`Применена ветка ${picked.branch} ✓ (остальные попытки удалены, отчёт: ${reportFile})`, "success");
		},
	});
}
