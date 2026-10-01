#!/bin/bash
# hyprlock-suspend.sh — monitor handling on suspend/resume.
# Called by a systemd service on suspend (pre) and resume (post).
#
# Hyprland 0.55 + Lua config: 'hyprctl keyword' is rejected and 'hyprctl dispatch
# dpms' is Lua-evaluated. Use hl.monitor via hyprctl eval and hl.dsp.dpms via
# hyprctl dispatch. NOTE: runs as root via elogind -- connectors are hardcoded
# (root cannot read the user's monitors-detected.conf); keep in sync with
# hyprland.lua if the cabling changes.

# Current external outputs (must match hyprland.lua / monitors-detect.sh).
DP="DP-1";       DP_MODE="1920x1080@74.97"; DP_POS="0x0"
HDMI="HDMI-A-2"; HDMI_MODE="1920x1080@75";  HDMI_POS="1920x0"

mon_disable() { hyprctl eval "hl.monitor({output=\"$1\", disabled=true})" >/dev/null 2>&1 || true; }
mon_enable()  { hyprctl eval "hl.monitor({output=\"$1\", mode=\"$2\", position=\"$3\", scale=1})" >/dev/null 2>&1 || true; }

case "$1" in
pre)
    # Before suspend -- disable externals + dpms off (only eDP stays for lock)
    mon_disable "$DP"
    mon_disable "$HDMI"
    hyprctl dispatch 'hl.dsp.dpms({action="off"})' >/dev/null 2>&1 || true
    ;;
post)
    # After resume -- dpms on, then re-enable externals
    hyprctl dispatch 'hl.dsp.dpms({action="on"})' >/dev/null 2>&1 || true
    sleep 0.5
    mon_enable "$DP"   "$DP_MODE"   "$DP_POS"
    mon_enable "$HDMI" "$HDMI_MODE" "$HDMI_POS"
    ;;
*)
    echo "Usage: $0 {pre|post}"
    exit 1
    ;;
esac

exit 0
