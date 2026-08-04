# ssh-agent-reuse.zsh — один ssh-agent на все shell-ы
# Сохраняет socket + PID в файл, переиспользует если жив.
# Заменяет eval "$(ssh-agent)" который плодил процесс на каждый shell.

__ssh_agent_env="$HOME/.ssh/agent.env"

__ssh_agent_start() {
  ssh-agent -s > "$__ssh_agent_env" 2>/dev/null
  . "$__ssh_agent_env" > /dev/null
}

__ssh_agent_cleanup_stale() {
  # Удаляем старые socket-файлы из ~/.ssh/agent/
  local agent_dir="$HOME/.ssh/agent"
  if [[ -d "$agent_dir" ]]; then
    for f in "$agent_dir"/s.*; do
      [[ -e "$f" ]] || continue
      # Если socket не привязан к живому процессу — удаляем
      local pid_file="${f%.agent.*}"
      if ! ss -lx 2>/dev/null | grep -q "$(basename "$f")"; then
        rm -f "$f" 2>/dev/null
      fi
    done
  fi
}

# Основная логика
if [[ -f "$__ssh_agent_env" ]]; then
  . "$__ssh_agent_env" > /dev/null 2>&1

  # Проверяем что процесс ещё жив
  if [[ -n "$SSH_AGENT_PID" ]] && kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    # Агент жив — переиспользуем
    return 0
  fi

  # Агент мёртв — запускаем новый
  __ssh_agent_start
else
  # Файла нет — первый запуск
  __ssh_agent_start
fi

# Периодическая очистка (не чаще раза в 24ч)
if [[ -f "$__ssh_agent_env" ]]; then
  local _cleanup_marker="$HOME/.ssh/agent/.last-cleanup"
  local _now=$(date +%s)
  local _last=0
  [[ -f "$_cleanup_marker" ]] && _last=$(stat -c %Y "$_cleanup_marker" 2>/dev/null || echo 0)
  if (( _now - _last > 86400 )); then
    __ssh_agent_cleanup_stale
    touch "$_cleanup_marker"
  fi
fi

unset __ssh_agent_env
