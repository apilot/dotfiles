#!/bin/sh
# Panorama overlay toggle (SUPER+Tab). Команда вне бинда: Lua-провайдер
# Hyprland ломает пайпы/кавычки/$env в exec-аргументах (кворк movecursor).
# A-фикс: аудит-лог каждого вызова — время, сокет, ответ демона, exit-код socat.
# Диагностика «leader+tab не сработал»: нет записи = bind не выполнился;
# reply пуст + exit≠0 = сокет недоступен; reply есть = демон обработал.
SOCK="${XDG_RUNTIME_DIR:-/run/user/1000}"/panorama.sock
LOG="${XDG_STATE_HOME:-$HOME/.local/state}"/panorama-toggle.log
R=$(printf 'toggle\n' | socat - UNIX-CONNECT:"$SOCK" 2>&1)
C=$?
mkdir -p "$(dirname "$LOG")" 2>/dev/null
echo "$(date '+%F %T') sock=$SOCK reply='$R' exit=$C" >> "$LOG"
