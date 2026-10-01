#!/bin/bash
# toggle_ext_monitors.sh — toggle external monitors with workspace reassignment.
# Keybinding: SUPER+SHIFT+M
#
# Connector names ($DP / $HDMI) are read from the file that monitors-detect.sh
# maintains, so this keeps working when the GPU port names change.
#   OFF: all workspaces 1-10 → eDP-1, external monitors disabled.
#   ON:  1-3 → eDP-1, 4-6 → $DP (left), 7-10 → $HDMI (right).
#
# Hyprland 0.55 + Lua config: 'hyprctl keyword' is rejected and 'hyprctl dispatch'
# is Lua-evaluated. Runtime monitor / workspace-rule changes go through
# 'hyprctl eval "...lua..."'.

# Runtime helpers (Lua API via hyprctl eval / dispatch).
mon_disable()       { hyprctl eval "hl.monitor({output=\"$1\", disabled=true})" >/dev/null 2>&1 || true; }
mon_enable()        { hyprctl eval "hl.monitor({output=\"$1\", mode=\"$2\", position=\"$3\", scale=$4})" >/dev/null 2>&1 || true; }
ws_rule()           { hyprctl eval "hl.workspace_rule({workspace=\"$1\", monitor=\"$2\"})" >/dev/null 2>&1 || true; }
ws_move_to_monitor(){ hyprctl dispatch "hl.dsp.workspace.move({workspace=\"$1\", monitor=\"$2\"})" >/dev/null 2>&1 || true; }

DETECTED_CONF="$HOME/.config/hypr/conf/monitors-detected.conf"
EDP="eDP-1"

# Read a $VAR value from the detected-monitors config file.
read_var() {
    local name="$1"
    [[ -f "$DETECTED_CONF" ]] || return 0
    awk -v n="$name" '
        $0 ~ ("[$]" n "[[:space:]]*=") {
            sub(/^[^=]*=[[:space:]]*/, "")
            gsub(/[[:space:]]/, "")
            print
            exit
        }
    ' "$DETECTED_CONF"
}

DP="$(read_var DP)";       DP="${DP:-DP-1}"
DP_RATE="$(read_var DP_RATE)"; DP_RATE="${DP_RATE:-60}"
HDMI="$(read_var HDMI)";   HDMI="${HDMI:-HDMI-A-2}"

is_ext_on() {
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name' | grep -qx -- "${HDMI}"
}

turn_off() {
    # 1. Move ALL active workspaces to the laptop (preserve windows)
    local ws
    for ws in $(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id' | sort -n); do
        [[ "$ws" -gt 0 ]] && ws_move_to_monitor "$ws" "$EDP"
    done

    # 2. Reassign all workspace bindings to eDP-1
    for ws in 1 2 3 4 5 6 7 8 9 10; do ws_rule "$ws" "$EDP"; done

    # 3. Disable the external monitors
    mon_disable "$DP"
    mon_disable "$HDMI"

    notify-send "Monitor Toggle" "OFF — все workspace на ${EDP}"
}

turn_on() {
    # 1. Enable external monitors (positions match hyprland.lua)
    mon_enable "$DP"   "1920x1080@${DP_RATE}" "0x0"     1
    mon_enable "$HDMI" "1920x1080@75"         "1920x0"  1

    sleep 1

    # 2. Reassign workspace bindings
    for ws in 1 2 3;    do ws_rule "$ws" "$EDP";  done
    for ws in 4 5 6;    do ws_rule "$ws" "$DP";   done
    for ws in 7 8 9 10; do ws_rule "$ws" "$HDMI"; done

    # 3. Move existing workspaces to their monitors
    for ws in 4 5 6;    do ws_move_to_monitor "$ws" "$DP";   done
    for ws in 7 8 9 10; do ws_move_to_monitor "$ws" "$HDMI"; done

    notify-send "Monitor Toggle" "ON — 1-3:${EDP}  4-6:${DP}  7-10:${HDMI}"
}

if is_ext_on; then
    turn_off
else
    turn_on
fi
