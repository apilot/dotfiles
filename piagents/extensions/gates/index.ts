/**
 * Gates — точка входа пакета гейтов безопасности.
 *
 * Активирует все гейты разом. Используется при загрузке каталога целиком
 * (глобально: ~/.pi/agent/extensions/gates/, локально: --extension extensions/gates).
 * Отдельные файлы тоже можно грузить по одному через --extension <файл>.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

import permissionGate from "./permission-gate.ts";
import protectedPaths from "./protected-paths.ts";
import toolAnnotations from "./tool-annotations.ts";
import todo from "./todo.ts";

export default function (pi: ExtensionAPI) {
	permissionGate(pi);
	protectedPaths(pi);
	toolAnnotations(pi);
	todo(pi);
}
