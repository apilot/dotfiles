#!/bin/sh
# elogind sleep hook for monitor handling on suspend/resume.
# Install at: /etc/elogind/system-sleep/hyprlock-monitors  (chmod +x)
#
# Hyprland 0.55 + Lua config: 'hyprctl keyword' rejected, 'hyprctl dispatch dpms'
# Lua-evaluated. Use hl.monitor (hyprctl eval) + hl.dsp.dpms (hyprctl dispatch).
# Runs as root via elogind -- connectors hardcoded (root can't read user conf);
# keep in sync with hyprland.lua.

DP="DP-1";       DP_MODE="1920x1080@74.97"; DP_POS="0x0"
HDMI="HDMI-A-2"; HDMI_MODE="1920x1080@75";  HDMI_POS="1920x0"

mon_disable() { hyprctl eval "hl.monitor({output=\"$1\", disabled=true})" >/dev/null 2>&1 || true; }
mon_enable()  { hyprctl eval "hl.monitor({output=\"$1\", mode=\"$2\", position=\"$3\", scale=1})" >/dev/null 2>&1 || true; }

case "${1-}" in
pre)
    # Before suspend -- disable externals + dpms off
    mon_disable "$DP"
    mon_disable "$HDMI"
    hyprctl dispatch 'hl.dsp.dpms({action="off"})' >/dev/null 2>&1 || true
    ;;
post)
    # After resume -- run in background (resume is flaky if elogind doesn't return fast)
    hyprctl dispatch 'hl.dsp.dpms({action="on"})' >/dev/null 2>&1 &
    sleep 0.5
    mon_enable "$DP"   "$DP_MODE"   "$DP_POS" &
    mon_enable "$HDMI" "$HDMI_MODE" "$HDMI_POS" &
    ;;
*)
    exit 1
    ;;
esac

exit 0
