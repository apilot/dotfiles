---
name: test-loop
description: Итеративные проверки и починка тестов одним codemode-скриптом с ограниченным циклом (≤5 итераций) вместо серии tool-вызовов. Используй при падающих тестах/валидации, когда нужны повторы run→parse→fix.
---

# Test Loop: одна петля — один codemode-скрипт

## Когда применять

Нужно прогнать тесты/валидацию и починить падающее — НЕ вызывай bash→read→edit по кругу
(N round-trips модели). Напиши ОДИН codemode-скрипт с циклом внутри.

## Скелет скрипта

```javascript
// codemode: тестовая петля, максимум 5 итераций
const MAX_ITER = 5;
for (let i = 1; i <= MAX_ITER; i++) {
  // 1) прогон (bash-инструмент внутри codemode)
  const run = await codemode.tools.bash({ command: "npm test -- --json 2>&1 || true" });

  // 2) разбор падений (структурно, не глазами модели)
  const failures = parseFailures(run.stdout); // JSON → [{file, test, error}]
  if (failures.length === 0) {
    console.log(`GREEN на итерации ${i}`);
    break;
  }

  // 3) параллельные точечные правки
  await Promise.all(failures.map(f =>
    codemode.tools.edit({ path: f.file, edits: [{ oldText: f.bad, newText: f.fixed }] })
  ));
  if (i === MAX_ITER) throw new Error(`Не зелёные за ${MAX_ITER} итераций: ` + failures.map(f=>f.test).join(", "));
}
```

## Правила

1. **Лимит итераций ≤ 5** — обязательно. Превышен лимит → throw с перечнем оставшихся падений
   (stop-on-failure: человек решает дальше).
2. Каждая итерация: run → parse → fix. Никаких «посмотрю ещё разок» сверх лимита.
3. Парсинг — кодом (JSON/regex), не пересказом модели.
4. Правки — минимальные и точечные (edit с oldText/newText), параллельно через Promise.all.
5. Кастомные тулы с outputSchema возвращают structuredContent — парсь его, а не текст.
6. Финальный вывод скрипта: статус (GREEN/FAILED), число итераций, список поправленного.
