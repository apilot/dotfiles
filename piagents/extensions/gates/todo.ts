/**
 * Todo — тул управления задачами + команда /todos.
 *
 * Адаптация официального примера examples/extensions/todo.ts:
 * - тул `todo` для модели (list / add / toggle / clear)
 * - состояние живёт в tool-result `details` → корректно переживает ветвление
 *   и восстанавливается из сессии (session_start / session_tree)
 * - /todos — просмотр списка в TUI
 */

import { StringEnum } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { matchesKey, Text, truncateToWidth } from "@earendil-works/pi-tui";
import { Type } from "typebox";

interface Todo {
	id: number;
	text: string;
	done: boolean;
}

interface TodoDetails {
	action: "list" | "add" | "toggle" | "clear";
	todos: Todo[];
	nextId: number;
	error?: string;
}

const TodoParams = Type.Object({
	action: StringEnum(["list", "add", "toggle", "clear"] as const),
	text: Type.Optional(Type.String({ description: "Текст задачи (для add)" })),
	id: Type.Optional(Type.Number({ description: "ID задачи (для toggle)" })),
});

/** UI-компонент списка для /todos (TUI). */
class TodoListComponent {
	private todos: Todo[];
	private theme: Theme;
	private onClose: () => void;
	private cachedWidth?: number;
	private cachedLines?: string[];

	constructor(todos: Todo[], theme: Theme, onClose: () => void) {
		this.todos = todos;
		this.theme = theme;
		this.onClose = onClose;
	}

	handleInput(data: string): void {
		if (matchesKey(data, "escape") || matchesKey(data, "ctrl+c")) {
			this.onClose();
		}
	}

	render(width: number): string[] {
		if (this.cachedLines && this.cachedWidth === width) {
			return this.cachedLines;
		}

		const lines: string[] = [];
		const th = this.theme;

		lines.push("");
		const title = th.fg("accent", " Todos ");
		const headerLine =
			th.fg("borderMuted", "─".repeat(3)) + title + th.fg("borderMuted", "─".repeat(Math.max(0, width - 10)));
		lines.push(truncateToWidth(headerLine, width));
		lines.push("");

		if (this.todos.length === 0) {
			lines.push(truncateToWidth(`  ${th.fg("dim", "Задач нет. Попроси агента добавить!")}`, width));
		} else {
			const done = this.todos.filter((t) => t.done).length;
			lines.push(truncateToWidth(`  ${th.fg("muted", `${done}/${this.todos.length} выполнено`)}`, width));
			lines.push("");
			for (const todo of this.todos) {
				const check = todo.done ? th.fg("success", "✓") : th.fg("dim", "○");
				const id = th.fg("accent", `#${todo.id}`);
				const text = todo.done ? th.fg("dim", todo.text) : th.fg("text", todo.text);
				lines.push(truncateToWidth(`  ${check} ${id} ${text}`, width));
			}
		}

		lines.push("");
		lines.push(truncateToWidth(`  ${th.fg("dim", "Escape — закрыть")}`, width));
		lines.push("");

		this.cachedWidth = width;
		this.cachedLines = lines;
		return lines;
	}

	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}
}

export default function (pi: ExtensionAPI) {
	let todos: Todo[] = [];
	let nextId = 1;

	/** Восстановление состояния из ветки сессии (последний details выигрывает). */
	const reconstructState = (ctx: ExtensionContext) => {
		todos = [];
		nextId = 1;
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type !== "message") continue;
			const msg = entry.message;
			if (msg.role !== "toolResult" || msg.toolName !== "todo") continue;
			const details = msg.details as TodoDetails | undefined;
			if (details) {
				todos = details.todos;
				nextId = details.nextId;
			}
		}
	};

	pi.on("session_start", async (_event, ctx) => reconstructState(ctx));
	pi.on("session_tree", async (_event, ctx) => reconstructState(ctx));

	pi.registerTool({
		name: "todo",
		label: "Todo",
		description: "Управление списком задач. Действия: list, add (text), toggle (id), clear",
		parameters: TodoParams,

		async execute(_toolCallId, params) {
			switch (params.action) {
				case "list":
					return {
						content: [
							{
								type: "text",
								text: todos.length
									? todos.map((t) => `[${t.done ? "x" : " "}] #${t.id}: ${t.text}`).join("\n")
									: "Задач нет",
							},
						],
						details: { action: "list", todos: [...todos], nextId } as TodoDetails,
					};

				case "add": {
					if (!params.text) {
						return {
							content: [{ type: "text", text: "Ошибка: для add нужен text" }],
							details: { action: "add", todos: [...todos], nextId, error: "text required" } as TodoDetails,
						};
					}
					const newTodo: Todo = { id: nextId++, text: params.text, done: false };
					todos.push(newTodo);
					return {
						content: [{ type: "text", text: `Добавлена задача #${newTodo.id}: ${newTodo.text}` }],
						details: { action: "add", todos: [...todos], nextId } as TodoDetails,
					};
				}

				case "toggle": {
					if (params.id === undefined) {
						return {
							content: [{ type: "text", text: "Ошибка: для toggle нужен id" }],
							details: { action: "toggle", todos: [...todos], nextId, error: "id required" } as TodoDetails,
						};
					}
					const todo = todos.find((t) => t.id === params.id);
					if (!todo) {
						return {
							content: [{ type: "text", text: `Задача #${params.id} не найдена` }],
							details: {
								action: "toggle",
								todos: [...todos],
								nextId,
								error: `#${params.id} not found`,
							} as TodoDetails,
						};
					}
					todo.done = !todo.done;
					return {
						content: [
							{ type: "text", text: `Задача #${todo.id} ${todo.done ? "выполнена" : "снова открыта"}` },
						],
						details: { action: "toggle", todos: [...todos], nextId } as TodoDetails,
					};
				}

				case "clear": {
					const count = todos.length;
					todos = [];
					nextId = 1;
					return {
						content: [{ type: "text", text: `Очищено задач: ${count}` }],
						details: { action: "clear", todos: [], nextId: 1 } as TodoDetails,
					};
				}
			}
		},

		renderCall(args, theme) {
			let text = theme.fg("toolTitle", theme.bold("todo ")) + theme.fg("muted", args.action);
			if (args.text) text += ` ${theme.fg("dim", `"${args.text}"`)}`;
			if (args.id !== undefined) text += ` ${theme.fg("accent", `#${args.id}`)}`;
			return new Text(text, 0, 0);
		},

		renderResult(result, { expanded }, theme) {
			const details = result.details as TodoDetails | undefined;
			if (!details) {
				const text = result.content[0];
				return new Text(text?.type === "text" ? text.text : "", 0, 0);
			}
			if (details.error) {
				return new Text(theme.fg("error", `Ошибка: ${details.error}`), 0, 0);
			}
			switch (details.action) {
				case "list": {
					if (details.todos.length === 0) return new Text(theme.fg("dim", "Задач нет"), 0, 0);
					let listText = theme.fg("muted", `${details.todos.length} задача(и):`);
					const display = expanded ? details.todos : details.todos.slice(0, 5);
					for (const t of display) {
						const check = t.done ? theme.fg("success", "✓") : theme.fg("dim", "○");
						listText += `\n${check} ${theme.fg("accent", `#${t.id}`)} ${theme.fg("muted", t.text)}`;
					}
					if (!expanded && details.todos.length > 5) {
						listText += `\n${theme.fg("dim", `... ещё ${details.todos.length - 5}`)}`;
					}
					return new Text(listText, 0, 0);
				}
				case "add": {
					const added = details.todos[details.todos.length - 1];
					return new Text(
						theme.fg("success", "✓ Добавлена ") +
							theme.fg("accent", `#${added.id}`) +
							" " +
							theme.fg("muted", added.text),
						0,
						0,
					);
				}
				case "toggle":
				case "clear": {
					const text = result.content[0];
					return new Text(theme.fg("success", "✓ ") + theme.fg("muted", text?.type === "text" ? text.text : ""), 0, 0);
				}
			}
		},
	});

	pi.registerCommand("todos", {
		description: "Показать список задач текущей ветки",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") {
				// не-TUI режимы: выводим текстом через notify
				const list = todos.length
					? todos.map((t) => `${t.done ? "[x]" : "[ ]"} #${t.id}: ${t.text}`).join("\n")
					: "Задач нет";
				ctx.ui.notify(`Todos:\n${list}`, "info");
				return;
			}
			await ctx.ui.custom<void>((_tui, theme, _kb, done) => {
				return new TodoListComponent(todos, theme, () => done());
			});
		},
	});
}
