#!/bin/bash

# Navigation mode switcher script for Hyprland (file-based approach)
# Usage: ./set_nav_mode.sh [standard|alternative|toggle|status]

MODE_FILE="$HOME/.config/hypr/.nav_mode"
HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
STANDARD_BINDINGS="$HOME/.config/hypr/nav_bindings_standard.conf"
ALTERNATIVE_BINDINGS="$HOME/.config/hypr/nav_bindings_alternative.conf"

# Read current mode or default to standard (0)
get_current_mode() {
    cat "$MODE_FILE" 2>/dev/null || echo "0"
}

# Send notification with optional urgency
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u "$urgency" -t 2000 "$title" "$message"
    fi

    # Also print to terminal for debugging
    echo "$title: $message"
}

# Clear all navigation-related bindings
clear_nav_bindings() {
    # Hyprland 0.55 + Lua config: 'hyprctl keyword unbind' is rejected; use
    # hl.unbind via hyprctl eval. (Note: nav_bindings_*.conf are currently absent,
    # so this feature is dormant -- the unbind keys aren't bound in hyprland.lua.)
    for key in H J K L semicolon; do
        hyprctl eval "hl.unbind(\"SUPER + $key\")"        >/dev/null 2>&1 || true
        hyprctl eval "hl.unbind(\"SUPER + SHIFT + $key\")" >/dev/null 2>&1 || true
    done
}

# Apply bindings from config file
apply_bindings() {
    local bindings_file="$1"
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        # Apply binding
        hyprctl keyword bind "${line#bind = }" 2>/dev/null || true
    done < "$bindings_file"
}

case "$1" in
    "standard")
        echo "0" > "$MODE_FILE"
        clear_nav_bindings
        apply_bindings "$STANDARD_BINDINGS"
        send_notification "Режим навигации" "СТАНДАРТНЫЙ режим активирован
h/j/k/l ←↓↑→ (vim-style)" "normal"
        ;;
    "alternative")
        echo "1" > "$MODE_FILE"
        clear_nav_bindings
        apply_bindings "$ALTERNATIVE_BINDINGS"
        send_notification "Режим навигации" "АЛЬТЕРНАТИВНЫЙ режим активирован
h → →  j ←  k ↓  l ↑  ; →" "normal"
        ;;
    "toggle")
        current=$(get_current_mode)
        if [ "$current" = "0" ]; then
            "$0" alternative
        else
            "$0" standard
        fi
        ;;
    "status")
        current=$(get_current_mode)
        if [ "$current" = "0" ]; then
            send_notification "Текущий режим" "СТАНДАРТНЫЙ
h/j/k/l ←↓↑→ (vim-style)" "low"
        else
            send_notification "Текущий режим" "АЛЬТЕРНАТИВНЫЙ
h → →  j ←  k ↓  l ↑  ; →" "low"
        fi
        ;;
    *)
        echo "Usage: $0 [standard|alternative|toggle|status]"
        echo "Current mode: $(get_current_mode) (0=standard, 1=alternative)"
        echo ""
        echo "Controls:"
        echo "  Super + ;        - Toggle between modes"
        echo "  Super + Shift + ; - Force standard mode"
        echo ""
        echo "Bindings:"
        echo "  Standard mode: h/j/k/l = ←↓↑→ (vim-style)"
        echo "  Alternative mode: h→ →, j←, k↓, l↑, ;→"
        echo "  Arrow keys (Super + ←→↑↓) always work as fallback"
        exit 1
        ;;
esac