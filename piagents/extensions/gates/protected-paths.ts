/**
 * Protected Paths Gate — запрет записи в чувствительные пути.
 *
 * Событие: tool_call (write, edit, bash). Защищено: .env*, .git/, node_modules/,
 * *.lock, ~/.pi/. Bash-редиректы (> >> tee) в защищённые пути тоже блокируются.
 * Лог блокировок пишется append-строками через withFileMutationQueue (read-modify-write
 * сериализация) в <cwd>/.pi/gates/blocked.jsonl (gitignored, только аудит).
 */

import { withFileMutationQueue, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { appendFile, mkdir } from "fs/promises";
import { basename, dirname, isAbsolute, join, resolve } from "path";
import { homedir } from "os";

/** Сегменты каталогов, куда запись запрещена. */
const PROTECTED_DIR_SEGMENTS = new Set([".git", "node_modules"]);

/** Абсолютный префикс домашнего каталога Pi (~/.pi). */
const PI_HOME = join(homedir(), ".pi");

/** true, если абсолютный путь попадает под защиту. */
function isProtected(absPath: string): boolean {
	const segments = absPath.split("/");
	const name = basename(absPath);

	// ~/.pi/ — целиком
	if (absPath === PI_HOME || absPath.startsWith(PI_HOME + "/")) return true;

	// .env и .env.*
	if (name === ".env" || name.startsWith(".env.")) return true;

	// *.lock
	if (name.endsWith(".lock")) return true;

	// .git/ и node_modules/ как сегмент пути
	return segments.some((s) => PROTECTED_DIR_SEGMENTS.has(s));
}

/** Разворачивает ~ и относительные пути против cwd. */
function resolvePath(raw: string, cwd: string): string {
	const expanded = raw.startsWith("~") ? join(homedir(), raw.slice(1)) : raw;
	return isAbsolute(expanded) ? expanded : resolve(cwd, expanded);
}

/** Извлекает цели записи из bash-команды: > path, >> path, | tee path. */
function bashWriteTargets(command: string): string[] {
	const targets: string[] = [];
	const re = /(?:>>|>|tee\s+(?:-a\s+)?)\s*([^\s;&|()]+)/g;
	let m: RegExpExecArray | null;
	while ((m = re.exec(command)) !== null) {
		if (m[1] !== "&1" && m[1] !== "&2") targets.push(m[1]);
	}
	return targets;
}

export default function (pi: ExtensionAPI) {
	const logBlock = (cwd: string, tool: string, target: string, reason: string) => {
		const logFile = join(cwd, ".pi", "gates", "blocked.jsonl");
		const line = JSON.stringify({ ts: new Date().toISOString(), gate: "protected-paths", tool, target, reason });
		// fire-and-forget: лог не должен ломать гейт
		void withFileMutationQueue(logFile, async () => {
			try {
				await mkdir(dirname(logFile), { recursive: true });
				await appendFile(logFile, line + "\n");
			} catch {
				/* аудит не критичен */
			}
		});
	};

	pi.on("tool_call", async (event, ctx) => {
		let target: string | undefined;
		let reason: string | undefined;

		if (event.toolName === "write" || event.toolName === "edit") {
			const raw = String(event.input.path ?? "");
			const abs = resolvePath(raw, ctx.cwd);
			if (isProtected(abs)) {
				target = raw;
				reason = `Путь "${raw}" защищён от записи (абс.: ${abs})`;
			}
		} else if (event.toolName === "bash") {
			const command = String(event.input.command ?? "");
			const hit = bashWriteTargets(command).find((t) => isProtected(resolvePath(t, ctx.cwd)));
			if (hit) {
				target = hit;
				reason = `Bash-редирект в защищённый путь "${hit}"`;
			}
		}

		if (!reason || !target) return undefined;

		logBlock(ctx.cwd, event.toolName, target, reason);
		if (ctx.hasUI) ctx.ui.notify(`Protected paths: ${reason}`, "warning");

		return { block: true, reason };
	});
}
