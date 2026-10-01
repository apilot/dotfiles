/**
 * Compaction & Test Gate — входная точка пакета.
 * code-aware.ts: код-осознанная компакция (сигнатуры/пути/диффы — сохраняем,
 * тела файлов и полные выводы тулов — выбрасываем) + триггер по порогу контекста.
 * test-gate.ts: стадия TEST не завершается при красной validation (лимит попыток).
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import codeAwareCompaction from "./code-aware.ts";
import { default as testGate } from "./test-gate.ts";

export default function (pi: ExtensionAPI) {
	codeAwareCompaction(pi);
	testGate(pi);
}
