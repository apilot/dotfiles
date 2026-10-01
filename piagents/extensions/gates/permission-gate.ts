/**
 * Permission Gate — подтверждение опасных bash-команд.
 *
 * Событие: tool_call (bash). Блокируемые паттерны: rm -rf, sudo, git push --force,
 * chmod/chown 777, curl|wget | sh/bash. Подтверждение через ctx.ui.confirm с
 * авто-отказом через 60 сек (timeout). Без UI (headless/print) — fail-closed: блок.
 * После блокировки terminate: true — стоп по принципу stop-on-failure.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Авто-отказ подтверждения, если пользователь не ответил за это время. */
const CONFIRM_TIMEOUT_MS = 60_000;

/** Простые паттерны: достаточно regex по всей команде. */
const SIMPLE_PATTERNS: Array<{ re: RegExp; label: string }> = [
	{ re: /\bsudo\b/, label: "sudo" },
	{ re: /\bgit\s+push\b[^|;&>]*\s(--force(\b|-with-lease)|-f\b)/, label: "git push --force" },
	{ re: /\b(chmod|chown)\b[^|;&]*\b777\b/, label: "chmod/chown 777" },
	// curl/wget, результат которого уходит прямо в shell
	{ re: /\b(curl|wget)\b[^|]*\|\s*(sudo\s+)?(ba|z|da)?sh\b/, label: "curl/wget | sh" },
];

/**
 * Детект `rm` с одновременно recursive и force в одном сегменте команды.
 * Понимает -rf, -fr, -r -f, --recursive --force в любом порядке.
 */
function isRecursiveForceRm(command: string): boolean {
	// грубо режем команду на сегменты по ; && || | — каждый оцениваем отдельно
	const segments = command.split(/(?:\|\||&&|;|\|)/);
	for (const raw of segments) {
		const seg = raw.trim();
		const m = seg.match(/(?:^|\s)rm\s+([^&]*)$/) ?? seg.match(/(?:^|\s)rm\s+([^&]*)/);
		if (!m) continue;
		const args = m[1].trim().split(/\s+/);
		let hasR = false;
		let hasF = false;
		for (const arg of args) {
			if (arg === "--recursive") hasR = true;
			else if (arg === "--force") hasF = true;
			else if (/^-[a-zA-Z]+$/.test(arg)) {
				// комбинированные короткие флаги: -rf, -fr, -ri...
				if (arg.includes("r")) hasR = true;
				if (arg.includes("f")) hasF = true;
			}
			// первый не-флаговый аргумент — дальше флагов не ждём
			if (!arg.startsWith("-")) break;
		}
		if (hasR && hasF) return true;
	}
	return false;
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return undefined;

		const command = String(event.input.command ?? "");
		const matched = isRecursiveForceRm(command)
			? "rm -rf"
			: SIMPLE_PATTERNS.find((p) => p.re.test(command))?.label;

		if (!matched) return undefined;

		// fail-closed: без UI подтверждение невозможно — блокируем
		if (!ctx.hasUI) {
			return {
				block: true,
				reason: `Опасная команда [${matched}] заблокирована гейтом (нет UI для подтверждения): ${command}`,
				terminate: true,
			};
		}

		const confirmed = await ctx.ui.confirm(
			`⚠️ Опасная команда: ${matched}`,
			`${command}\n\nВыполнить? (авто-отказ через 60 сек)`,
			{ timeout: CONFIRM_TIMEOUT_MS },
		);

		if (!confirmed) {
			if (ctx.hasUI) ctx.ui.notify(`Заблокировано: ${matched}`, "warning");
			return {
				block: true,
				reason: `Команда [${matched}] не подтверждена пользователем: ${command}`,
				terminate: true,
			};
		}

		return undefined;
	});
}
