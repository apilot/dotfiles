/**
 * OAC Router — виртуальная модель с роутингом по GLM-флоту.
 *
 * Эвристики (бесплатные, без классификатора):
 *  - стадии SPEC/PLAN/APPROVE/REVIEW (.pi/pipeline.state.json) → glm-5.3, thinking high
 *  - стадии IMPL/TEST → glm-5.3 делает первый edit, затем stage-aware свитч на glm-5.3-flash
 *  - direct-запросы (компакция и т.п.) и простые обращения → glm-5-turbo
 *  - retry после переполнения контекста → glm-5.3-flash (1M контекст)
 *  - sticky: continuation/retry остаются на модели прошлого ответа (кэш промптов)
 *  - fallback: любая ошибка роутинга → glm-5.3 (route() не бросает исключений)
 *
 * Команда /router-stats — распределение решений (из pi.appendEntry, не из контекста).
 * Использование: pi -e <этот файл> --model oac/router
 */

import { readFileSync } from "fs";
import { join } from "path";
import type { Message } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, ModelRoute, ModelRouteRequest } from "@earendil-works/pi-coding-agent";

const PROVIDER = "zai";
const STRONG = "glm-5.3";
const FLASH = "glm-5.3-flash";
const TURBO = "glm-5-turbo";

const STATS_ENTRY = "router-stats";

interface RouterState {
	phase: "reason" | "implement";
}

type RouteRequest = ModelRouteRequest<RouterState>;

/** Тулы, чей успешный результат означает начало имплементации. */
const EDIT_TOOLS = new Set(["edit", "write"]);

function lastUserText(messages: readonly Message[]): string {
	const content = messages.filter((m) => m.role === "user").at(-1)?.content ?? "";
	if (typeof content === "string") return content;
	return content.flatMap((b) => (b.type === "text" ? [b.text] : [])).join("\n");
}

function editedThisTurn(messages: readonly Message[]): boolean {
	const lastUser = messages.findLastIndex((m) => m.role === "user");
	return messages
		.slice(lastUser + 1)
		.some((m) => m.role === "toolResult" && EDIT_TOOLS.has(m.toolName) && !m.isError);
}

/** Стадия пайплайна из снапшота (дёшево, без зависимости от расширения pipeline). */
function readStage(cwd: string): string | null {
	try {
		return (JSON.parse(readFileSync(join(cwd, ".pi", "pipeline.state.json"), "utf8")) as { stage?: string }).stage ?? null;
	} catch {
		return null;
	}
}

/** Простые обращения: короткий текст, команды просмотра/поиска. */
function looksSimple(text: string): boolean {
	const t = text.toLowerCase();
	if (text.length > 400) return false;
	return /(покажи|найди|список|запусти|проверь|выведи|show|list|find|run|grep|ls)\b/.test(t) || text.length < 80;
}

export default function (pi: ExtensionAPI) {
	// --- статистика решений -----------------------------------------------------
	let counters = new Map<string, number>();
	let last: Array<{ model: string; reason: string; stage: string | null; phase: string }> = [];

	const reconstruct = (ctx: ExtensionContext) => {
		counters = new Map();
		last = [];
		for (const e of ctx.sessionManager.getBranch()) {
			const entry = e as { type: string; customType?: string; data?: { model: string; reason: string; stage: string | null; phase: string } };
			if (entry.type !== "custom" || entry.customType !== STATS_ENTRY || !entry.data) continue;
			counters.set(entry.data.model, (counters.get(entry.data.model) ?? 0) + 1);
			last.push(entry.data);
		}
	};
	pi.on("session_start", async (_e, ctx) => reconstruct(ctx));

	const recordDecision = (model: string, reason: string, stage: string | null, phase: string) => {
		counters.set(model, (counters.get(model) ?? 0) + 1);
		last.push({ model, reason, stage, phase });
		if (last.length > 50) last = last.slice(-50);
		pi.appendEntry(STATS_ENTRY, { model, reason, stage, phase, ts: new Date().toISOString() });
	};

	// --- виртуальная модель -----------------------------------------------------
	pi.registerVirtualModel<RouterState>({
		provider: "oac",
		id: "router",
		name: "OAC Router (GLM fleet)",
		thinkingLevels: ["low", "medium", "high"],
		contextWindow: 200_000,
		maxTokens: 131_072,

		async route(request: RouteRequest, ctx: ExtensionContext): Promise<ModelRoute<RouterState>> {
			const pick = (id: string, thinkingLevel: string, state?: RouterState): ModelRoute<RouterState> => {
				const model = ctx.modelRegistry.find(PROVIDER, id);
				if (!model) throw new Error(`${PROVIDER}/${id} нет в каталоге`);
				return { model, thinkingLevel, state };
			};

			let stage: string | null = null;
			try {
				stage = readStage(ctx.cwd);
			} catch {
				stage = null;
			}

			const state = request.state ?? { phase: "reason" };
			const log = (id: string, extra?: Partial<{ st: RouterState }>) => {
				recordDecision(id, request.reason, stage, extra?.st?.phase ?? state.phase);
			};

			try {
				// direct (компакция, streamSimple) — дёшево
				if (request.reason === "direct") {
					log(TURBO);
					return pick(TURBO, "low");
				}

				// retry: переполнение контекста → модель с 1M контекстом
				if (request.reason === "retry" && request.failed) {
					const overflow = /context|too large|превыш/i.test(request.failed.message.errorMessage ?? "");
					const id = overflow ? FLASH : (request.failed.model?.id ?? STRONG);
					log(id);
					return pick(id, overflow ? "high" : (request.failed.thinkingLevel ?? "high"));
				}

				// stage-aware свитч после первого успешного edit (паттерн jev-router)
				if (state.phase === "reason" && request.reason === "continuation" && editedThisTurn(request.messages)) {
					const next: RouterState = { phase: "implement" };
					log(FLASH, { st: next });
					return pick(FLASH, "high", next);
				}

				// continuation/retry: sticky — сохраняем кэш промптов
				if (request.reason !== "user" && request.previous?.model) {
					log(request.previous.model.id);
					return {
						model: request.previous.model,
						thinkingLevel: request.previous.thinkingLevel ?? "medium",
					};
				}

				// новый ход пользователя — решаем по стадии и содержанию
				if (stage === "SPEC" || stage === "PLAN" || stage === "APPROVE" || stage === "REVIEW") {
					log(STRONG);
					return pick(STRONG, "high", state);
				}
				if (stage === "IMPL" || stage === "TEST") {
					// сильная модель планирует правки; после первого edit свитч на flash (выше)
					const id = state.phase === "implement" ? FLASH : STRONG;
					log(id);
					return pick(id, "high", state);
				}

				// без пайплайна: эвристика по запросу
				const text = lastUserText(request.messages);
				const id = looksSimple(text) ? TURBO : STRONG;
				log(id);
				return pick(id, id === TURBO ? "low" : "high", state);
			} catch (err) {
				// fallback: роутер не должен ронять сессию
				recordDecision(`${STRONG} (fallback: ${(err as Error).message.slice(0, 50)})`, request.reason, stage, state.phase);
				return pick(STRONG, "medium", state);
			}
		},
	});

	// --- /router-stats ----------------------------------------------------------
	pi.registerCommand("router-stats", {
		description: "Статистика решений OAC Router (текущая сессия)",
		handler: async (_args, ctx) => {
			reconstruct(ctx);
			if (counters.size === 0) {
				ctx.ui.notify("Router: решений пока нет (модель oac/router не использовалась в этой сессии)", "info");
				return;
			}
			const table = [...counters.entries()]
				.sort((a, b) => b[1] - a[1])
				.map(([m, n]) => `  ${m}: ${n}`)
				.join("\n");
			ctx.ui.notify(`Router stats:\n${table}\n\nПоследние: ${last.slice(-5).map((d) => `${d.model} (${d.reason}${d.stage ? `, ${d.stage}` : ""})`).join(" → ")}`, "info");
		},
	});
}
