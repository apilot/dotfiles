/**
 * Taskgraph — парсинг plan.md, топологическая сортировка, батчи параллельности,
 * состояние воркеров (в pi.appendEntry, НЕ в контексте модели).
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export interface PlanTask {
	id: string;
	title: string;
	dependsOn: string[];
	files: string[];
	validation: string;
}

export type TaskStatus = "pending" | "running" | "done" | "failed" | "conflict" | "blocked";

export interface TaskState {
	id: string;
	title: string;
	status: TaskStatus;
	branch?: string;
	worktree?: string;
	validation?: string;
	summary?: string;
	reason?: string;
	startedAt?: string;
	finishedAt?: string;
}

export const WORKERS_ENTRY = "workers-state";

/** Парсер задач plan.md (формат prompts/plan.md; устойчив к лишним полям). */
export function parsePlanTasks(planMd: string): PlanTask[] {
	const tasks: PlanTask[] = [];
	let cur: Partial<PlanTask> | null = null;
	for (const rawLine of planMd.split("\n")) {
		const line = rawLine.trim();
		let m = line.match(/^-\s+id:\s*(\S+)/);
		if (m) {
			if (cur?.id) tasks.push(cur as PlanTask);
			cur = { id: m[1], title: "", dependsOn: [], files: [], validation: "" };
			continue;
		}
		if (!cur) continue;
		if ((m = line.match(/^title:\s*(.+)$/))) {
			cur.title = m[1].trim();
		} else if ((m = line.match(/^depends_on:\s*\[(.*)\]$/))) {
			cur.dependsOn = m[1].split(",").map((s) => s.trim().replace(/^['"]|['"]$/g, "")).filter(Boolean);
		} else if ((m = line.match(/^files:\s*\[(.*)\]$/))) {
			cur.files = m[1].split(",").map((s) => s.trim().replace(/^['"]|['"]$/g, "")).filter(Boolean);
		} else if ((m = line.match(/^validation:\s*(.+)$/))) {
			cur.validation = m[1].trim();
		}
	}
	if (cur?.id) tasks.push(cur as PlanTask);
	return tasks;
}

export class GraphError extends Error {}

/** Топологическая сортировка по уровням: каждый уровень — независимые задачи (батч). */
export function topoBatches(tasks: PlanTask[]): PlanTask[][] {
	const byId = new Map(tasks.map((t) => [t.id, t]));
	for (const t of tasks) {
		for (const dep of t.dependsOn) {
			if (!byId.has(dep)) throw new GraphError(`задача ${t.id}: неизвестная зависимость ${dep}`);
		}
	}
	// циклы
	const state = new Map<string, 0 | 1 | 2>();
	const visit = (id: string) => {
		const s = state.get(id);
		if (s === 2) return;
		if (s === 1) throw new GraphError(`цикл зависимостей, включающий ${id}`);
		state.set(id, 1);
		for (const dep of byId.get(id)!.dependsOn) visit(dep);
		state.set(id, 2);
	};
	tasks.forEach((t) => visit(t.id));

	const batches: PlanTask[][] = [];
	const placed = new Set<string>();
	let remaining = [...tasks];
	while (remaining.length) {
		const batch = remaining.filter((t) => t.dependsOn.every((d) => placed.has(d)));
		if (batch.length === 0) throw new GraphError("не удалось разрешить зависимости");
		batches.push(batch);
		batch.forEach((t) => placed.add(t.id));
		remaining = remaining.filter((t) => !placed.has(t.id));
	}
	return batches;
}

/** In-memory состояние + снапшоты в сессию. */
export function createWorkersState(pi: ExtensionAPI) {
	let states: TaskState[] = [];
	let slug = "";

	const snapshot = () => {
		pi.appendEntry(WORKERS_ENTRY, { slug, tasks: states.map((s) => ({ ...s })), ts: new Date().toISOString() });
	};

	return {
		get slug() {
			return slug;
		},
		get tasks() {
			return states;
		},
		init(newSlug: string, tasks: PlanTask[]) {
			slug = newSlug;
			states = tasks.map((t) => ({ id: t.id, title: t.title, status: "pending" as TaskStatus }));
			snapshot();
		},
		update(id: string, patch: Partial<TaskState>) {
			const t = states.find((s) => s.id === id);
			if (!t) return;
			Object.assign(t, patch);
			snapshot();
		},
		/** Блокирует незапущенные задачи (stop-on-failure). */
		blockRemaining(reason: string) {
			for (const t of states) {
				if (t.status === "pending") {
					t.status = "blocked";
					t.reason = reason;
				}
			}
			snapshot();
		},
		compact(): string {
			if (!states.length) return "Воркеры не запускались (task_dispatch <slug>).";
			const lines = states.map(
				(s) => `${s.status === "done" ? "✓" : s.status === "failed" || s.status === "conflict" ? "✗" : s.status === "running" ? "⏳" : "·"} ${s.id} [${s.status}] ${s.title}${s.reason ? ` — ${s.reason}` : ""}`,
			);
			return `Задача ${slug}:\n${lines.join("\n")}`;
		},
		/** Восстановление из последней записи ветки (для task_status в новой сессии). */
		restore(branch: Array<{ type: string; customType?: string; data?: any }>): boolean {
			for (let i = branch.length - 1; i >= 0; i--) {
				const e = branch[i];
				if (e.type === "custom" && e.customType === WORKERS_ENTRY && e.data?.tasks) {
					slug = e.data.slug ?? "";
					states = e.data.tasks;
					return true;
				}
			}
			return false;
		},
	};
}
