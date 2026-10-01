/**
 * Pipeline State — состояние пайплайна разработки.
 *
 * Стадии: SPEC → PLAN → APPROVE → IMPL → TEST → REVIEW → DONE (+ INACTIVE — пайплайн не запущен).
 * Хранение: pi.appendEntry("pipeline-state") — durable, вне контекста модели (основное);
 * файл .pi/pipeline.state.json — снапшот для восстановления в новой сессии.
 * Восстановление: последняя запись в ветке сессии → файл → INACTIVE.
 */

import { withFileMutationQueue, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "fs";
import { mkdir, writeFile } from "fs/promises";
import { dirname, join } from "path";

export const STAGES = ["SPEC", "PLAN", "APPROVE", "IMPL", "TEST", "REVIEW", "DONE"] as const;
export type Stage = (typeof STAGES)[number];
export type PipelineStage = Stage | "INACTIVE";

export interface PipelineState {
	stage: PipelineStage;
	slug?: string;
}

export const STATE_ENTRY = "pipeline-state";

/** Разрешённые переходы. Пусто = переход запрещён (см. hint). */
export const TRANSITIONS: Record<PipelineStage, Stage[]> = {
	INACTIVE: [],
	SPEC: ["PLAN"],
	PLAN: [], // в IMPL — только через /approve
	APPROVE: ["PLAN"], // отказ возвращает к PLAN
	IMPL: ["TEST"],
	TEST: ["REVIEW"],
	REVIEW: ["DONE"],
	DONE: [], // заморожено; выход — /stage reset
};

export function stateFile(cwd: string): string {
	return join(cwd, ".pi", "pipeline.state.json");
}

export interface PipelineStore {
	get(): PipelineState;
	set(next: PipelineState, cwd: string): void;
	restore(branch: Array<{ type: string; customType?: string; data?: unknown }>, cwd: string): PipelineState;
}

export function createPipelineStore(pi: ExtensionAPI): PipelineStore {
	let current: PipelineState = { stage: "INACTIVE" };

	const persistFile = (cwd: string) => {
		const file = stateFile(cwd);
		void withFileMutationQueue(file, async () => {
			try {
				await mkdir(dirname(file), { recursive: true });
				await writeFile(file, JSON.stringify({ ...current, updatedAt: new Date().toISOString() }, null, 2));
			} catch {
				/* снапшот не критичен: основное хранилище — записи сессии */
			}
		});
	};

	return {
		get: () => current,

		set(next: PipelineState, cwd: string) {
			current = next;
			pi.appendEntry(STATE_ENTRY, { ...next, ts: new Date().toISOString() });
			persistFile(cwd);
		},

		restore(branch, cwd) {
			for (let i = branch.length - 1; i >= 0; i--) {
				const e = branch[i] as { type: string; customType?: string; data?: PipelineState };
				if (e.type === "custom" && e.customType === STATE_ENTRY && e.data) {
					current = { stage: e.data.stage, slug: e.data.slug };
					return current;
				}
			}
			// новой сессии записей нет — пробуем файловый снапшот
			try {
				const raw = JSON.parse(readFileSync(stateFile(cwd), "utf8")) as PipelineState;
				if (raw && (raw.stage === "INACTIVE" || (STAGES as readonly string[]).includes(raw.stage))) {
					current = { stage: raw.stage, slug: raw.slug };
					return current;
				}
			} catch {
				/* нет файла — INACTIVE */
			}
			current = { stage: "INACTIVE" };
			return current;
		},
	};
}

/** Текст статуса для футера. */
export function statusText(s: PipelineState): string {
	return s.stage === "INACTIVE" ? "STAGE: —" : `STAGE: ${s.stage}${s.slug ? ` | task: ${s.slug}` : ""}`;
}
