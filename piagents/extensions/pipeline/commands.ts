/**
 * Pipeline Commands — /spec, /plan, /impl.
 *
 * Управляют стадиями и отправляют промпт из шаблонов prompts/{spec,plan,impl}.md
 * (подстановка {{SLUG}} и $ARGUMENTS). Шаблоны — источник текста, состояние — здесь.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "fs";
import { join } from "path";
import { fileURLToPath } from "url";
import type { PipelineStore } from "./state.ts";

const PROMPTS_DIR = fileURLToPath(new URL("../../prompts/", import.meta.url));

function loadTemplate(name: "spec" | "plan" | "impl", slug: string, args: string): string {
	const raw = readFileSync(join(PROMPTS_DIR, `${name}.md`), "utf8");
	return raw.replaceAll("{{SLUG}}", slug).replace("$ARGUMENTS", args.trim() || "(описание не дано)");
}

const SLUG_RE = /^[a-z0-9][a-z0-9-]*$/;

/** Парсит "<slug> <rest...>" из аргументов команды. */
function parseSlugArgs(args: string): { slug?: string; rest: string } {
	const parts = args.trim().split(/\s+/).filter(Boolean);
	if (parts.length && SLUG_RE.test(parts[0])) {
		return { slug: parts[0], rest: parts.slice(1).join(" ") };
	}
	return { rest: args.trim() };
}

export function registerPipelineCommands(pi: ExtensionAPI, store: PipelineStore, updateFooter: (stage: string, slug: string | undefined, ctx: { ui: { setStatus(key: string, text: string | undefined): void } }) => void) {
	// /spec <slug> <описание>
	pi.registerCommand("spec", {
		description: "Начать задачу: стадия SPEC, шаблон спецификации (slug + описание)",
		handler: async (args, ctx) => {
			const { slug, rest } = parseSlugArgs(args);
			if (!slug) {
				ctx.ui.notify("Формат: /spec <slug> <описание>. Slug — kebab-case, станет docs/tasks/<slug>/", "error");
				return;
			}
			store.set({ stage: "SPEC", slug }, ctx.cwd);
			updateFooter("SPEC", slug, ctx);
			await pi.sendUserMessage(loadTemplate("spec", slug, rest));
		},
	});

	// /plan [slug]
	pi.registerCommand("plan", {
		description: "Стадия PLAN: план из docs/tasks/<slug>/spec.md (шаблон plan.md)",
		handler: async (args, ctx) => {
			const { slug: argSlug } = parseSlugArgs(args);
			const slug = argSlug ?? store.get().slug;
			if (!slug) {
				ctx.ui.notify("Нет активной задачи. Укажи: /plan <slug> или /task <slug>", "error");
				return;
			}
			try {
				readFileSync(join(ctx.cwd, "docs", "tasks", slug, "spec.md"));
			} catch {
				ctx.ui.notify(`Не найден docs/tasks/${slug}/spec.md — сначала /spec ${slug} <описание>`, "error");
				return;
			}
			store.set({ stage: "PLAN", slug }, ctx.cwd);
			updateFooter("PLAN", slug, ctx);
			await pi.sendUserMessage(loadTemplate("plan", slug, ""));
		},
	});

	// /impl
	pi.registerCommand("impl", {
		description: "Стадия IMPL: выполнить утверждённый план из docs/tasks/<slug>/plan.md",
		handler: async (_args, ctx) => {
			const current = store.get();
			if (!current.slug) {
				ctx.ui.notify("Нет активной задачи: /task <slug>", "error");
				return;
			}
			if (current.stage !== "IMPL") {
				ctx.ui.notify(
					current.stage === "PLAN" || current.stage === "APPROVE"
						? `Стадия ${current.stage}: сначала утверди план — /approve`
						: `Стадия ${current.stage}, а нужна IMPL. /stage — статус`,
					"error",
				);
				return;
			}
			updateFooter(current.stage, current.slug, ctx);
			await pi.sendUserMessage(loadTemplate("impl", current.slug, ""));
		},
	});
}
