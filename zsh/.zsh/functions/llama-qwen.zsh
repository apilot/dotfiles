# llama.cpp Qwen2.5-Coder local server management
# Поддержка двух моделей:
#   3b → Qwen2.5-Coder-3B-Instruct Q5_K_M (для opencode-агента, 32K ctx)
#   7b → Qwen2.5-Coder-7B-Instruct Q4_K_M  (для FIM/quick chat, 16K ctx)
#
# ВАЖНО: одновременно можно запускать ТОЛЬКО ОДНУ (VRAM 6 GB не вмещает обе).
# Команды:
#   qwen-up [3b|7b]   запустить (без аргумента = 3b)
#   qwen-down [3b|7b] остановить (без аргумента = все запущенные)
#   qwen-status       статус всех
#   qwen-log [3b|7b]  лог (по умолчанию 3b)
#   qwen-switch 7b    остановить текущую + запустить другую

# --- Model registry ---
typeset -A QWEN_MODEL_PATH QWEN_PORT QWEN_CTX QWEN_KV
QWEN_MODEL_PATH[3b]="/home/aboyarinov/storage/llama/models/qwen2.5-coder-3b-instruct-q5_k_m.gguf"
QWEN_MODEL_PATH[7b]="/home/aboyarinov/storage/llama/models/qwen2.5-coder-7b-instruct-q4_k_m.gguf"
QWEN_PORT[3b]=8080
QWEN_PORT[7b]=8081
QWEN_CTX[3b]=32768
QWEN_CTX[7b]=16384
QWEN_KV[3b]=q8_0
QWEN_KV[7b]=q4_0

QWEN_HOST="127.0.0.1"
QWEN_CACHE_DIR="${QWEN_CACHE_DIR:-$HOME/.cache}"

_qwen_pidfile() { echo "$QWEN_CACHE_DIR/llama-qwen-$1.pid"; }
_qwen_logfile() { echo "$QWEN_CACHE_DIR/llama-qwen-$1.log"; }

_qwen_start() {
  local size="$1"
  [[ -z "$size" ]] && { echo "✗ Не указан размер (3b/7b)"; return 1; }
  [[ -z "${QWEN_MODEL_PATH[$size]}" ]] && { echo "✗ Неизвестный размер: $size"; return 1; }

  local port="${QWEN_PORT[$size]}"
  local ctx="${QWEN_CTX[$size]}"
  local kv="${QWEN_KV[$size]}"
  local model="${QWEN_MODEL_PATH[$size]}"
  local pidfile=$(_qwen_pidfile "$size")
  local logfile=$(_qwen_logfile "$size")

  if curl -sf "http://$QWEN_HOST:$port/health" >/dev/null 2>&1; then
    echo "✓ $size уже запущен (PID $(cat "$pidfile" 2>/dev/null), :$port)"
    return 0
  fi

  mkdir -p "$(dirname "$logfile")"

  echo "→ Запускаю $size ($model)"
  echo "  ctx=$ctx  kv=$kv  port=$port"
  nohup llama-server \
    -m "$model" \
    -ngl 99 -c "$ctx" -t 8 \
    -fa on --jinja \
    -ctk "$kv" -ctv "$kv" \
    -sm none -mg 0 \
    --host "$QWEN_HOST" --port "$port" \
    > "$logfile" 2>&1 &

  echo $! > "$pidfile"

  echo -n "→ Ожидание health"
  for i in {1..60}; do
    if curl -sf "http://$QWEN_HOST:$port/health" >/dev/null 2>&1; then
      echo
      echo "✓ $size готов (PID $(cat "$pidfile"), http://$QWEN_HOST:$port)"
      echo "  Лог: tail -f $logfile"
      return 0
    fi
    echo -n "."
    sleep 1
  done
  echo
  echo "✗ Таймаут $size. Лог: tail -50 $logfile"
  return 1
}

_qwen_stop() {
  local size="$1"
  local pidfile=$(_qwen_pidfile "$size")
  if [[ -f "$pidfile" ]]; then
    local pid=$(cat "$pidfile")
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" && sleep 1
      kill -0 "$pid" 2>/dev/null && kill -9 "$pid"
      echo "✓ $size остановлен (PID $pid)"
    else
      echo "✓ $size процесс уже мёртв"
    fi
    rm -f "$pidfile"
  else
    local port="${QWEN_PORT[$size]}"
    if pkill -f "llama-server.*--port $port"; then
      echo "✓ $size убит через pkill (PID-файла не было)"
    else
      echo "✗ $size не запущен"
    fi
  fi
}

qwen-up() {
  local size="${1:-3b}"
  case "$size" in
    3b|7b) _qwen_start "$size" ;;
    all)    _qwen_start 3b && _qwen_start 7b ;;
    *) echo "Usage: qwen-up [3b|7b|all]  (по умолчанию 3b)"; return 1 ;;
  esac
}

qwen-down() {
  local size="$1"
  if [[ -z "$size" ]]; then
    # Остановить все запущенные
    for s in 3b 7b; do
      local port="${QWEN_PORT[$s]}"
      if curl -sf "http://$QWEN_HOST:$port/health" >/dev/null 2>&1 || [[ -f $(_qwen_pidfile "$s") ]]; then
        _qwen_stop "$s"
      fi
    done
  else
    case "$size" in
      3b|7b) _qwen_stop "$size" ;;
      *) echo "Usage: qwen-down [3b|7b]  (без аргумента = все)"; return 1 ;;
    esac
  fi
}

qwen-status() {
  local any_running=0
  for s in 3b 7b; do
    local port="${QWEN_PORT[$s]}"
    if curl -sf "http://$QWEN_HOST:$port/health" >/dev/null 2>&1; then
      local pid=$(cat "$(_qwen_pidfile "$s")" 2>/dev/null || echo '?')
      local ctx="${QWEN_CTX[$s]}"
      echo "✓ $s  running  (PID $pid, http://$QWEN_HOST:$port, ctx=$ctx)"
      any_running=1
    else
      echo "✗ $s  stopped"
    fi
  done
  [[ "$any_running" -eq 0 ]] && return 1
  return 0
}

qwen-log() {
  local size="${1:-3b}"
  local n="${2:-30}"
  case "$size" in
    3b|7b) tail -n "$n" "$(_qwen_logfile "$size")" ;;
    *) echo "Usage: qwen-log [3b|7b] [lines]  (по умолчанию 3b, 30 строк)" ;;
  esac
}

qwen-switch() {
  local target="$1"
  case "$target" in
    3b|7b)
      qwen-down
      sleep 1
      qwen-up "$target"
      ;;
    *) echo "Usage: qwen-switch [3b|7b]" ;;
  esac
}
