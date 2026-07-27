#!/bin/bash
# lock-with-monitors.sh — lock the screen keeping only the laptop active.
# Disables the externals before locking (so the lock screen is on eDP-1 only),
# re-enables them after unlock. Keybind: SUPER+SHIFT+L
#
# Hyprland 0.55 + Lua config: monitor changes via 'hyprctl eval "hl.monitor(...)"'.
# External connector names are read from monitors-detected.conf (kept current by
# monitors-detect.sh) — the legacy hardcoded DVI-I-1/HDMI-A-1 names are gone.

DETECTED_CONF="$HOME/.config/hypr/conf/monitors-detected.conf"
read_var() {
    local name="$1"
    [[ -f "$DETECTED_CONF" ]] || return 0
    awk -v n="$name" '
        $0 ~ ("[$]" n "[[:space:]]*=") { sub(/^[^=]*=[[:space:]]*/, ""); gsub(/[[:space:]]/, ""); print; exit }
    ' "$DETECTED_CONF"
}
DP="$(read_var DP)";       DP="${DP:-DP-1}"
DP_RATE="$(read_var DP_RATE)"; DP_RATE="${DP_RATE:-60}"
HDMI="$(read_var HDMI)";   HDMI="${HDMI:-HDMI-A-2}"

mon_disable() { hyprctl eval "hl.monitor({output=\"$1\", disabled=true})" >/dev/null 2>&1 || true; }
mon_enable()  { hyprctl eval "hl.monitor({output=\"$1\", mode=\"$2\", position=\"$3\", scale=$4})" >/dev/null 2>&1 || true; }

# Disable externals before locking
mon_disable "$DP"
mon_disable "$HDMI"
sleep 0.5

# Lock (blocks until unlock)
hyprlock

# Re-enable externals after unlock (positions match hyprland.lua)
mon_enable "$DP"   "1920x1080@${DP_RATE}" "0x0"    1
mon_enable "$HDMI" "1920x1080@75"         "1920x0" 1
