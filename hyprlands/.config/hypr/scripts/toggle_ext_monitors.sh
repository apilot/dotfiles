#!/bin/bash
# toggle_ext_monitors.sh — toggle external monitors with workspace reassignment
# Keybinding: SUPER+SHIFT+M
# OFF: all workspaces 1-10 → eDP-1
# ON:  1-3 → eDP-1, 4-6 → DVI-I-1, 7-10 → HDMI-A-1

DVI="DVI-I-1"
HDMI="HDMI-A-1"
EDP="eDP-1"

is_ext_on() {
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name' | grep -q "^${HDMI}$"
}

dvi_active() {
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name' | grep -q "^${DVI}$"
}

turn_off() {
    # 1. Move ALL active workspaces to eDP-1 (preserve windows)
    for ws in $(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id' | sort -n); do
        [ "$ws" -gt 0 ] && hyprctl dispatch moveworkspacetomonitor "${ws} ${EDP}" 2>/dev/null || true
    done

    # 2. Reassign workspace bindings to eDP-1
    for ws in 1 2 3 4 5 6 7 8 9 10; do
        hyprctl keyword workspace "${ws},monitor:${EDP}" 2>/dev/null || true
    done

    # 3. Disable HDMI-A-1
    hyprctl keyword monitor "${HDMI},disable"

    # 4. Stop DisplayLink service
    sudo rc-service displaylink stop 2>/dev/null || true

    notify-send "Monitor Toggle" "OFF — все workspace на ${EDP}"
}

turn_on() {
    # 1. Start DisplayLink service
    sudo rc-service displaylink zap
    sudo rc-service displaylink start

    # 2. Enable DVI-I-1 (DisplayLink) — position from hyprland.conf
    hyprctl keyword monitor "${DVI},1920x1080@60,0x0,1"

    # 3. Enable HDMI-A-1
    hyprctl keyword monitor "${HDMI},1920x1080@75,1920x0,1"

    # 4. Wait for monitors to appear
    sleep 2

    # 5. Fallback: trigger udev if DVI not detected (EVDI race condition)
    if ! dvi_active; then
        sudo udevadm trigger --action=change /sys/class/drm/card2-DVI-I-1 2>/dev/null || true
        sleep 2
    fi

    # 6. Reassign workspace bindings
    for ws in 1 2 3; do
        hyprctl keyword workspace "${ws},monitor:${EDP}" 2>/dev/null || true
    done
    for ws in 4 5 6; do
        hyprctl keyword workspace "${ws},monitor:${DVI}" 2>/dev/null || true
    done
    for ws in 7 8 9 10; do
        hyprctl keyword workspace "${ws},monitor:${HDMI}" 2>/dev/null || true
    done

    # 7. Move existing workspaces to their monitors
    for ws in 4 5 6; do
        hyprctl dispatch moveworkspacetomonitor "${ws} ${DVI}" 2>/dev/null || true
    done
    for ws in 7 8 9 10; do
        hyprctl dispatch moveworkspacetomonitor "${ws} ${HDMI}" 2>/dev/null || true
    done

    notify-send "Monitor Toggle" "ON — 1-3:${EDP}  4-6:${DVI}  7-10:${HDMI}"
}

# Main toggle
if is_ext_on; then
    turn_off
else
    turn_on
fi
