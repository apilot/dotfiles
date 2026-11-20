# herdr + herdr-app: пакеты GNU stow

- **Дата**: 2026-11-20
- **Статус**: done (gentoo `87852fdc` → cherry-pick на master `4d5ed94a`, ubuntu `9c881d35`)

## Кроссплатформенность

Репо используется на разных машинах (ветки gentoo/ubuntu/master), поэтому:
- symlinks создаются относительные (stow по умолчанию), репо ожидается в `~/dotfiles`;
- в трекаемых файлах нет машинно-специфичных путей и данных (проверено grep'ом);
- runtime-state (`shared.json` с IP, `session.json`, сессии, сокеты) — локальный на каждой машине, в репо не попадает.

## Задача

Добавить конфиги herdr (CLI/TUI + server-часть `herdr-core serve`) и herdr-app (GUI)
в репозиторий как stow-пакеты. Репозиторий публичный — ключи, IP и прочие
чувствительные данные в репо не попадают.

## Разбор

- `herdr-service` как отдельной сущности нет — это server-часть того же бинарника
  (`herdr-core serve`), конфиг общий: `~/.config/herdr/config.toml`. Отдельный пакет не нужен.
- `herdr-app/keys.json` — hotkey-биндинги, не API-ключи. Чистый, трекаем.
- IP (удалённая машина) найден только в runtime-state (`herdr-app/shared.json`,
  `herdr/session.json`, `sessions/`, `session-snapshots/`) — эти файлы в пакеты не входят.
- `mods/`, `installed.json`, `*.d.ts`, `frame/`, `data/`, `telemetry/`, `update-notes*`,
  `plugins*` — управляются приложением/автогенерируются, не трекаем.

## Решение

Два stow-пакета, миграция без рестарта приложений (stow делает посимвольные
symlinks внутрь существующих непустых директорий; runtime-файлы остаются жить рядом):

```
herdr/.config/herdr/config.toml
herdr-app/.config/herdr-app/settings.json
herdr-app/.config/herdr-app/keys.json
herdr-app/.config/herdr-app/layouts/{main,terminals,lazyvim,catppuccin,win98}.json + catppuccin.png + win98.svg
herdr-app/.config/herdr-app/themes/*.json
```

Команда миграции: `stow --adopt -t ~ herdr herdr-app` (из корня репо; adopt
переносит живой контент в пакет и линкует).

## Проверка

- grep по всем файлам пакетов на IP/ключи/токены перед коммитом — чисто.
- Symlinks созданы, runtime-файлы не тронуты, приложения не рестартовались.
