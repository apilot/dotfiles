/**
 * Code-Aware Compaction — код-осознанная компакция контекста.
 *
 * session_before_compact: сериализует диалог (serializeConversation) и генерирует
 * summary через дешёвую модель (glm-5.3-flash) с промптом, сохраняющим сигнатуры
 * функций, пути файлов и смысл диффов, но выбрасывающим тела файлов и полные
 * выводы тулов. Fallback: если модель недоступна — default compaction (return undefined).
 *
 * Триггер по контексту (паттерн trigger-compact.ts): порог THRESHOLD_TOKENS,
 * пересечение снизу вверх на turn_end → ctx.compact().
 *
 * Per-model бюджеты: compaction.modelOverrides в настройках проекта (.pi/settings.json).
 */

import { uuidv7 } from "@earendil-works/pi-ai";
import { convertToLlm, serializeConversation, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const SUMMARIZER_PROVIDER = "zai";
const SUMMARIZER_MODEL = "glm-5.3-flash";

/** Порог ручного триггера компакции по контексту. */
const THRESHOLD_TOKENS = 120_000;

const SUMMARY_PROMPT = `Ты — суммаризатор сессии разработки. Сожми диалог, СОХРАНИВ продуктивный контекст для продолжения работы.

ОБЯЗАТЕЛЬНО сохрани (дословно, где важно):
- Сигнатуры созданных/изменённых функций и типов (имя, параметры, возврат)
- Пути всех затронутых файлов и что с ними сделано (создан/изменён/удалён)
- Суть диффов: что было → что стало (без полных листингов)
- Решения и их причины, открытые вопросы, следующие шаги
- Названия задач/стадий пайплайна, slug активной задачи

ВЫБРОСЬ без сожаления:
- Тела файлов целиком, полные листинги кода
- Полные выводы тулов (тестов, bash, read) — оставь только итоги и статусы
- Повторы, рассуждения, не повлиявшие на результат

Формат: markdown с разделами Goal / Progress / Key decisions / Files (путь — что сделано — сигнатуры) / Next steps.`;

export default function (pi: ExtensionAPI) {
	// --- код-осознанная компакция ------------------------------------------------
	pi.on("session_before_compact", async (event, ctx) => {
		const { preparation, signal } = event;
		const { messagesToSummarize, turnPrefixMessages, tokensBefore, firstKeptEntryId, previousSummary } = preparation;

		const model = ctx.modelRegistry.find(SUMMARIZER_PROVIDER, SUMMARIZER_MODEL);
		if (!model) {
			if (ctx.hasUI) ctx.ui.notify("code-aware: суммаризатор недоступен, default compaction", "warning");
			return; // default compaction
		}

		const allMessages = [...messagesToSummarize, ...turnPrefixMessages];
		if (allMessages.length === 0) return;

		const conversationText = serializeConversation(convertToLlm(allMessages));
		const previousContext = previousSummary ? `\n\nПредыдущий summary (учти и его):\n${previousSummary}` : "";

		try {
			const response = await ctx.modelRegistry.complete(
				model,
				{
					messages: [
						{
							role: "user" as const,
							content: [
								{
									type: "text" as const,
									text: `${SUMMARY_PROMPT}${previousContext}\n\n<conversation>\n${conversationText}\n</conversation>`,
								},
							],
							timestamp: Date.now(),
						},
					],
				},
				{
					maxTokens: 8192,
					signal,
					cacheRetention: "none",
					sessionId: uuidv7(),
				},
			);

			const text = response.content
				.filter((b): b is { type: "text"; text: string } => b.type === "text")
				.map((b) => b.text)
				.join("\n")
				.trim();
			if (!text) return; // пустой ответ → default compaction

			if (ctx.hasUI) ctx.ui.notify(`code-aware compaction: ${tokensBefore.toLocaleString()} токенов → summary`, "info");

			return {
				compaction: {
					summary: text,
					firstKeptEntryId,
					tokensBefore,
					usage: response.usage,
					details: { gate: "code-aware", summarizer: `${SUMMARIZER_PROVIDER}/${SUMMARIZER_MODEL}` },
				},
			};
		} catch (err) {
			if (ctx.hasUI) ctx.ui.notify(`code-aware compaction fallthrough: ${(err as Error).message}`, "warning");
			return; // default compaction
		}
	});

	// --- триггер по порогу контекста ----------------------------------------------
	let previousTokens: number | null | undefined;
	pi.on("turn_end", (_event, ctx) => {
		const usage = ctx.getContextUsage();
		const current = usage?.tokens ?? null;
		if (current === null) return;
		const crossed = previousTokens != null && previousTokens <= THRESHOLD_TOKENS && current > THRESHOLD_TOKENS;
		previousTokens = current;
		if (!crossed) return;
		ctx.compact({
			customInstructions: "Сохрани сигнатуры функций, пути файлов и решения; выбрось тела файлов и полные выводы тулов.",
		});
	});
}
