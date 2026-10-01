/**
 * Tool Annotations Gate — approval кастомных/MCP-тулов по их annotations.
 *
 * Паттерн из доков extensions (MCP ToolAnnotations). Встроенные тулы (bash/edit/write...)
 * НЕ проверяются — их покрывают permission-gate и protected-paths (иначе двойной confirm).
 * Без UI (headless): блокируем только явно деструктивные (destructiveHint === true),
 * остальное пропускаем — иначе неинтерактивные прогоны становятся невозможными.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Встроенные тулы Pi — исключены из annotation-approval. */
const BUILTIN_PREFIX = "builtin:";

/** Таймаут подтверждения. */
const CONFIRM_TIMEOUT_MS = 60_000;

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		const tool = pi.getAllTools().find((t) => t.name === event.toolName);
		if (!tool) return undefined;

		// встроенные тулы покрывают специализированные гейты
		if (tool.sourceInfo.path.startsWith(BUILTIN_PREFIX)) return undefined;

		const hints = tool.annotations;
		if (!hints) return undefined; // без annotations решение не принимаем

		const needsApproval =
			hints.destructiveHint === true ||
			(!hints.readOnlyHint && ((hints.destructiveHint ?? true) || (hints.openWorldHint ?? true)));

		if (!needsApproval) return undefined;

		if (!ctx.hasUI) {
			// headless: fail-closed только для явно деструктивных
			if (hints.destructiveHint === true) {
				return {
					block: true,
					reason: `Тул ${event.toolName} помечен как destructive — в headless-режиме требует ручного запуска`,
				};
			}
			return undefined;
		}

		const confirmed = await ctx.ui.confirm(
			`⚠️ Вызов тула: ${event.toolName}`,
			`Annotations: readOnly=${hints.readOnlyHint ?? "?"} destructive=${hints.destructiveHint ?? "?"} openWorld=${hints.openWorldHint ?? "?"}\n\nПодтвердить вызов? (авто-отказ через 60 сек)`,
			{ timeout: CONFIRM_TIMEOUT_MS },
		);

		if (!confirmed) {
			return { block: true, reason: `${event.toolName} не подтверждён пользователем` };
		}

		return undefined;
	});
}
