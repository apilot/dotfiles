/**
 * Spawn — запуск воркера (изолированный субагент) в git worktree.
 *
 * Воркер = процесс `pi --mode json -p --no-session --model zai/glm-5.3-flash`
 * с cwd = worktree и системным промптом роли из extensions/workers/prompts/worker.md.
 * Паттерн запуска — из официального примера subagent/.
 */

import { spawn } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import type { Message } from "@earendil-works/pi-ai";
import type { PlanTask } from "./taskgraph.ts";

/** Модель воркера-исполнителя (быстрая, дешёвая). */
export const WORKER_MODEL = "zai/glm-5.3-flash";

/** Жёсткий лимит на работу воркера. */
const WORKER_TIMEOUT_MS = 10 * 60 * 1000;

const WORKER_PROMPT = fileURLToPath(new URL("./prompts/worker.md", import.meta.url));

export interface WorkerResult {
	exitCode: number;
	output: string;
	model?: string;
	error?: string;
}

function getFinalOutput(messages: Message[]): string {
	for (let i = messages.length - 1; i >= 0; i--) {
		const msg = messages[i];
		if (msg.role === "assistant") {
			for (const part of msg.content) {
				if (part.type === "text") return part.text;
			}
		}
	}
	return "";
}

function getPiInvocation(args: string[]): { command: string; args: string[] } {
	const currentScript = process.argv[1];
	if (currentScript && fs.existsSync(currentScript)) {
		return { command: process.execPath, args: [currentScript, ...args] };
	}
	return { command: "pi", args };
}

/** Собирает ввод воркера: текст задачи + контекст (MVI: список файлов, не содержимое). */
function buildTaskInput(slug: string, task: PlanTask): string {
	const deps = task.dependsOn.length ? task.dependsOn.join(", ") : "нет";
	const files = task.files.length ? task.files.join(", ") : "(список файлов не указан — определи сам)";
	return [
		`Задача из плана ${slug}:`,
		`ID: ${task.id}`,
		`Название: ${task.title}`,
		`Зависимости (уже выполнены): ${deps}`,
		`Ожидаемые файлы: ${files}`,
		`Validation-команда (для самопроверки, прогони её перед финальным ответом): ${task.validation || "(не задана)"}`,
		"",
		"Прочитай нужные файлы, выполни задачу минимальными правками, прогони validation при наличии.",
		"НЕ коммить изменения — merge сделает оркестратор.",
	].join("\n");
}

export async function runWorker(opts: {
	slug: string;
	task: PlanTask;
	worktree: string;
	signal?: AbortSignal;
}): Promise<WorkerResult> {
	const { slug, task, worktree, signal } = opts;

	const args: string[] = [
		"--mode",
		"json",
		"-p",
		"--no-session",
		"--model",
		WORKER_MODEL,
		"--append-system-prompt",
		WORKER_PROMPT,
		buildTaskInput(slug, task),
	];

	// временный файл системного промпта не нужен: --append-system-prompt принимает путь —
	// наш файл постоянный (extensions/workers/prompts/worker.md), ничего не создаём.

	const messages: Message[] = [];
	let stderr = "";
	let model: string | undefined;
	let timedOut = false;

	const exitCode = await new Promise<number>((resolve) => {
		const invocation = getPiInvocation(args);
		const proc = spawn(invocation.command, invocation.args, {
			cwd: worktree,
			shell: false,
			stdio: ["ignore", "pipe", "pipe"],
		});
		let buffer = "";

		const processLine = (line: string) => {
			if (!line.trim()) return;
			let event: any;
			try {
				event = JSON.parse(line);
			} catch {
				return;
			}
			if (event.type === "message_end" && event.message) {
				const msg = event.message as Message;
				messages.push(msg);
				if (msg.role === "assistant" && !model && msg.model) model = msg.model;
			}
		};

		proc.stdout.on("data", (data) => {
			buffer += data.toString();
			const lines = buffer.split("\n");
			buffer = lines.pop() || "";
			for (const line of lines) processLine(line);
		});
		proc.stderr.on("data", (data) => {
			stderr += data.toString();
		});
		proc.on("close", (code) => {
			if (buffer.trim()) processLine(buffer);
			resolve(code ?? 0);
		});
		proc.on("error", () => resolve(1));

		const timer = setTimeout(() => {
			timedOut = true;
			proc.kill("SIGTERM");
			setTimeout(() => proc.kill("SIGKILL"), 5000);
		}, WORKER_TIMEOUT_MS);
		proc.on("close", () => clearTimeout(timer));

		if (signal) {
			const kill = () => {
				timedOut = true;
				proc.kill("SIGTERM");
			};
			if (signal.aborted) kill();
			else signal.addEventListener("abort", kill, { once: true });
		}
	});

	const output = getFinalOutput(messages) || "(без вывода)";
	const error =
		timedOut
			? "таймаут воркера (10 мин)"
			: exitCode !== 0
				? stderr.trim().slice(0, 500) || `exit ${exitCode}`
				: undefined;

	return { exitCode, output, model, error };
}

/** Ограничение параллельности (из примера subagent/). */
export async function mapWithConcurrencyLimit<TIn, TOut>(
	items: TIn[],
	concurrency: number,
	fn: (item: TIn) => Promise<TOut>,
): Promise<TOut[]> {
	if (items.length === 0) return [];
	const limit = Math.max(1, Math.min(concurrency, items.length));
	const results: TOut[] = new Array(items.length);
	let next = 0;
	const runners = Array.from({ length: limit }, async () => {
		while (true) {
			const i = next++;
			if (i >= items.length) return;
			results[i] = await fn(items[i]);
		}
	});
	await Promise.all(runners);
	return results;
}
