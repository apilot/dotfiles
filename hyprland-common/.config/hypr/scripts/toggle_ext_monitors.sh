#!/bin/bash
# toggle_ext_monitors.sh — toggle external monitors with workspace reassignment.
# Keybinding: SUPER+SHIFT+M
#
# Connector names ($DP / $HDMI) are read from the file that monitors-detect.sh
# maintains, so this keeps working when the GPU port names change.
#   OFF: all workspaces 1-10 → eDP-1, external monitors disabled.
#   ON:  1-3 → eDP-1, 4-6 → $DP (left), 7-10 → $HDMI (right).

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
        [[ "$ws" -gt 0 ]] && hyprctl dispatch moveworkspacetomonitor "${ws} ${EDP}" 2>/dev/null || true
    done

    # 2. Reassign all workspace bindings to eDP-1
    for ws in 1 2 3 4 5 6 7 8 9 10; do
        hyprctl keyword workspace "${ws},monitor:${EDP}" 2>/dev/null || true
    done

    # 3. Disable the external monitors
    hyprctl keyword monitor "${DP},disable"   2>/dev/null || true
    hyprctl keyword monitor "${HDMI},disable" 2>/dev/null || true

    notify-send "Monitor Toggle" "OFF — все workspace на ${EDP}"
}

turn_on() {
    # 1. Enable external monitors (positions match monitors.conf)
    hyprctl keyword monitor "${DP},1920x1080@${DP_RATE},0x0,1"      2>/dev/null || true
    hyprctl keyword monitor "${HDMI},1920x1080@75,1920x0,1"         2>/dev/null || true

    sleep 1

    # 2. Reassign workspace bindings
    for ws in 1 2 3;    do hyprctl keyword workspace "${ws},monitor:${EDP}"  2>/dev/null || true; done
    for ws in 4 5 6;    do hyprctl keyword workspace "${ws},monitor:${DP}"   2>/dev/null || true; done
    for ws in 7 8 9 10; do hyprctl keyword workspace "${ws},monitor:${HDMI}" 2>/dev/null || true; done

    # 3. Move existing workspaces to their monitors
    for ws in 4 5 6;    do hyprctl dispatch moveworkspacetomonitor "${ws} ${DP}"   2>/dev/null || true; done
    for ws in 7 8 9 10; do hyprctl dispatch moveworkspacetomonitor "${ws} ${HDMI}" 2>/dev/null || true; done

    notify-send "Monitor Toggle" "ON — 1-3:${EDP}  4-6:${DP}  7-10:${HDMI}"
}

if is_ext_on; then
    turn_off
else
    turn_on
fi
