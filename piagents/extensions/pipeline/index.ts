/**
 * Pipeline — state machine цикла разработки: гейты по стадиям + /stage + /task.
 *
 * До APPROVE (SPEC/PLAN/APPROVE): write/edit разрешены ТОЛЬКО в docs/tasks/<slug>/,
 * bash — только read-only (whitelist). IMPL/TEST/REVIEW: правки разрешены, docs/
 * вне активной задачи защищён. DONE: всё заморожено. INACTIVE: гейты не действуют.
 *
 * Команды: /stage [next|set <S>|reset] [--force], /task [<slug>].
 * /spec, /plan, /impl — в commands.ts; /approve — в approve.ts.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isAbsolute, join, relative, resolve } from "path";
import { registerPipelineCommands } from "./commands.ts";
import { registerApproveCommand } from "./approve.ts";
import { registerBestofCommand } from "./bestof.ts";
import { createPipelineStore, statusText, STAGES, TRANSITIONS, type PipelineStage, type Stage } from "./state.ts";

/** Read-only команды bash (по первому токену каждого сегмента). */
const RO_COMMANDS = new Set([
	"ls", "cat", "head", "tail", "grep", "rg", "find", "pwd", "which", "wc", "echo",
	"file", "stat", "du", "df", "ps", "whoami", "date", "true", "false", "test", "node", "git", "npm",
]);

/** git-подкоманды, считающиеся read-only. */
const RO_GIT = new Set(["status", "diff", "log", "show", "branch", "remote", "rev-parse", "ls-files", "stash"]);

/** Мутирующие маркеры внутри сегмента команды. */
const MUTATION_RE = /(^|[^>])>{1,2}\s*\S|\btee\b|\brm\b|\bmv\b|\bcp\b|\btouch\b|\bmkdir\b|\brmdir\b|\bchmod\b|\bchown\b|\bsed\s+(-i|--in-place)|\bgit\s+(commit|add|push|pull|merge|rebase|checkout|switch|reset|stash\s+(push|pop)|worktree|clean|restore)\b|\bnpm\s+(install|i|ci|run|publish|update)\b|\bnpx\b|\bpip\b|\bcurl\b|\bwget\b/;

/** Команда считается read-only, если каждый сегмент whitelist-команда без мутаций. */
function isReadOnlyBash(command: string): boolean {
	const segments = command.split(/&&|\|\||;|\|/);
	return segments.every((seg) => {
		const trimmed = seg.trim();
		if (!trimmed) return true;
		const tokens = trimmed.split(/\s+/);
		const head = tokens[0];
		if (head === "git") return RO_GIT.has(tokens[1] ?? "");
		if (head === "node") return /^-[ev]$/.test(tokens[1] ?? ""); // node -e без записи? -e исполняет код — нет
		if (head === "npm") return tokens[1] === "ls" || tokens[1] === "list" || tokens[1] === "view";
		if (!RO_COMMANDS.has(head)) return false;
		return !MUTATION_RE.test(seg);
	});
}

/** Проверяет допустимость пути для write/edit на стадии. */
function checkPath(absPath: string, stage: PipelineStage, slug: string | undefined, cwd: string): string | undefined {
	if (stage === "INACTIVE") return undefined;

	const rel = relative(cwd, absPath);
	const inRepo = rel !== "" && !rel.startsWith("..") && !isAbsolute(rel);
	const taskDir = slug ? join("docs", "tasks", slug) : null;
	const inTaskDir = !!taskDir && (rel === taskDir || rel.startsWith(taskDir + "/"));
	const inDocs = rel === "docs" || rel.startsWith("docs/");

	if (stage === "SPEC" || stage === "PLAN" || stage === "APPROVE") {
		if (inTaskDir) return undefined;
		return `стадия ${stage}: правки заблокированы, разрешено только в ${taskDir ?? "docs/tasks/<slug>/"} (жду /approve)`;
	}
	if (stage === "IMPL" || stage === "TEST" || stage === "REVIEW") {
		if (!inRepo) return `стадия ${stage}: запись вне репозитория проекта запрещена`;
		if (inDocs && !inTaskDir) return `стадия ${stage}: docs/ защищён вне активной задачи ${taskDir}`;
		return undefined;
	}
	// DONE
	return "стадия DONE: репозиторий заморожен (/stage reset — начать новую задачу)";
}

const normalizeStage = (raw: string): PipelineStage | undefined =>
	raw === "INACTIVE" || (STAGES as readonly string[]).includes(raw) ? (raw as PipelineStage) : undefined;

export default function (pi: ExtensionAPI) {
	const store = createPipelineStore(pi);

	type CtxLike = { ui: { setStatus(key: string, text: string | undefined): void } };
	const updateFooter = (stage: string, slug: string | undefined, ctx: CtxLike) => {
		ctx.ui.setStatus("pipeline", statusText({ stage: stage as PipelineStage, slug }));
	};

	pi.on("session_start", async (_event, ctx) => {
		store.restore(ctx.sessionManager.getBranch() as never, ctx.cwd);
		updateFooter(store.get().stage, store.get().slug, ctx);
	});

	// --- Гейты по стадиям -------------------------------------------------------
	pi.on("tool_call", async (event, ctx) => {
		const { stage, slug } = store.get();
		if (stage === "INACTIVE") return undefined;

		if (event.toolName === "write" || event.toolName === "edit") {
			const raw = String(event.input.path ?? "");
			const reason = checkPath(resolve(ctx.cwd, raw), stage, slug, ctx.cwd);
			if (reason) return { block: true, reason: `Путь "${raw}": ${reason}` };
			return undefined;
		}

		if (event.toolName === "bash") {
			const command = String(event.input.command ?? "");
			const mutating = !isReadOnlyBash(command);
			if (mutating) {
				if (stage === "SPEC" || stage === "PLAN" || stage === "APPROVE") {
					return {
						block: true,
						reason: `стадия ${stage}: мутации заблокированы, жду /approve. Команда: ${command}`,
					};
				}
				if (stage === "DONE") {
					return { block: true, reason: `стадия DONE: репозиторий заморожен. Команда: ${command}` };
				}
			}
			return undefined;
		}

		return undefined;
	});

	// --- /task ------------------------------------------------------------------
	pi.registerCommand("task", {
		description: "Показать/установить активную задачу (slug папки в docs/tasks/)",
		handler: async (args, ctx) => {
			const arg = args.trim();
			const current = store.get();
			if (!arg) {
				ctx.ui.notify(
					current.slug
						? `Активная задача: ${current.slug} (стадия ${current.stage})`
						: `Активной задачи нет. Установи: /task <slug>`,
					"info",
				);
				return;
			}
			if (!/^[a-z0-9][a-z0-9-]*$/.test(arg)) {
				ctx.ui.notify(`Некорректный slug: "${arg}" (формат: kebab-case)`, "error");
				return;
			}
			store.set({ stage: current.stage, slug: arg }, ctx.cwd);
			updateFooter(current.stage, arg, ctx);
			ctx.ui.notify(`Активная задача: ${arg} (стадия ${current.stage})`, "info");
		},
	});

	// --- /stage -----------------------------------------------------------------
	pi.registerCommand("stage", {
		description: "Стадия пайплайна: показать | next | set <STAGE> | reset",
		handler: async (args, ctx) => {
			const [sub, target, ...rest] = args.trim().split(/\s+/).filter(Boolean);
			const force = rest.includes("--force");
			const current = store.get();

			const show = () => {
				const nexts = TRANSITIONS[current.stage];
				const hint =
					current.stage === "PLAN"
						? "переход в IMPL — только через /approve"
						: current.stage === "DONE"
							? "задача закрыта: /stage reset"
							: `переходы: ${nexts.map((s) => `/stage set ${s}`).join(" | ")}`;
				ctx.ui.notify(
					`Стадия: ${current.stage}${current.slug ? ` | задача: ${current.slug}` : ""}\n` +
						(current.stage === "INACTIVE"
							? "Пайплайн не активен. Начни задачу: /spec <slug> <описание> или /task <slug>"
							: hint),
					"info",
				);
			};

			if (!sub) return show();

			if (sub === "next") {
				const nexts = TRANSITIONS[current.stage];
				if (nexts.length === 0) {
					ctx.ui.notify(
						current.stage === "PLAN"
							? "Из PLAN переход только через /approve"
							: `Из ${current.stage} прямого перехода нет (${current.stage === "DONE" ? "/stage reset" : ""})`,
						"warning",
					);
					return;
				}
				if (nexts.length > 1 || current.stage === "INACTIVE") return show();
				return setStage(nexts[0]);
			}

			if (sub === "set") {
				const st = target ? normalizeStage(target.toUpperCase()) : undefined;
				if (!st) {
					ctx.ui.notify(`Неизвестная стадия "${target ?? ""}". Доступны: ${STAGES.join(", ")}, INACTIVE`, "error");
					return;
				}
				return setStage(st);
			}

			if (sub === "reset") {
				if (!force && ctx.hasUI) {
					const ok = await ctx.ui.confirm("Сбросить пайплайн?", "Стадия → INACTIVE, активная задача очищается.");
					if (!ok) return;
				}
				store.set({ stage: "INACTIVE" }, ctx.cwd);
				updateFooter("INACTIVE", undefined, ctx);
				ctx.ui.notify("Пайплайн сброшен (INACTIVE)", "info");
				return;
			}

			return show();

			async function setStage(next: Stage | "INACTIVE") {
				const allowed = TRANSITIONS[current.stage] as PipelineStage[];
				const isLegal = allowed.includes(next);
				if (!isLegal && !force) {
					ctx.ui.notify(
						`Переход ${current.stage} → ${next} запрещён. ${current.stage === "PLAN" && next === "IMPL" ? "Используй /approve." : `Разрешено: ${allowed.length ? allowed.join(", ") : "нет (только /approve или reset)"}`}`,
						"error",
					);
					return;
				}
				if (force && !isLegal) {
					ctx.ui.notify(`ВНИМАНИЕ: принудительный переход ${current.stage} → ${next} (--force)`, "warning");
				}
				store.set({ stage: next, slug: current.slug }, ctx.cwd);
				updateFooter(next, current.slug, ctx);
				ctx.ui.notify(`Стадия: ${next}${current.slug ? ` | задача: ${current.slug}` : ""}`, "info");
			}
		},
	});

	// --- /spec, /plan, /impl (commands.ts), /approve, /bestof -------------------
	registerPipelineCommands(pi, store, updateFooter);
	registerApproveCommand(pi, store, updateFooter);
	registerBestofCommand(pi);
}
