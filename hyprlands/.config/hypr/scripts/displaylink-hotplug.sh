#!/bin/bash
# displaylink-hotplug.sh — detect active EVDI DVI port, update $DL variable, reload Hyprland
#
# EVDI assigns DVI-I-1 or DVI-I-2 arbitrarily on reconnect.
# This script:
#   1. Detects which EVDI DVI port is connected
#   2. Updates ~/.config/hypr/conf/displaylink.conf ($DL variable)
#   3. Reloads Hyprland config
#
# Usage:
#   displaylink-hotplug.sh            # detect and reconfigure
#   displaylink-hotplug.sh --dry-run  # show what would change
#   displaylink-hotplug.sh --status   # show EVDI port status only

set -euo pipefail

# ── Paths ────────────────────────────────────────────────────────────────────
DL_CONF="$HOME/.config/hypr/conf/displaylink.conf"

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Helpers ──────────────────────────────────────────────────────────────────
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── Detection ────────────────────────────────────────────────────────────────
detect_evdi_port() {
    local card_dir port_name driver_target status

    for card_dir in /sys/class/drm/card*-DVI-I-*; do
        [ -d "$card_dir" ] || continue

        port_name="${card_dir##*/}"
        port_name="${port_name#card[0-9]*-}"

        driver_target=$(readlink -f "${card_dir}/device/driver" 2>/dev/null || true)
        [[ "$driver_target" != *"/evdi."* ]] && continue

        if [ -f "${card_dir}/status" ]; then
            status=$(cat "${card_dir}/status" 2>/dev/null || echo "unknown")
            if [ "$status" = "connected" ]; then
                echo "$port_name"
                return 0
            fi
        fi
    done
    return 1
}

# ── Status display ───────────────────────────────────────────────────────────
show_status() {
    local card_dir port_name driver_target status found=0

    echo -e "${CYAN}EVDI DVI Port Status${NC}"
    echo "─────────────────────────────────"

    for card_dir in /sys/class/drm/card*-DVI-I-*; do
        [ -d "$card_dir" ] || continue

        port_name="${card_dir##*/}"
        port_name="${port_name#card[0-9]*-}"

        driver_target=$(readlink -f "${card_dir}/device/driver" 2>/dev/null || true)
        [[ "$driver_target" != *"/evdi."* ]] && continue

        found=1
        status=$(cat "${card_dir}/status" 2>/dev/null || echo "unknown")

        local marker=""
        [ "$status" = "connected" ] && marker="${GREEN} ◄ connected${NC}"
        printf "  %-10s  status=%-12s%s\n" "$port_name" "$status" "$marker"
    done

    [ "$found" -eq 0 ] && warn "No EVDI DVI ports found."

    echo ""
    if [ -f "$DL_CONF" ]; then
        echo "Current config: $(cat "$DL_CONF" | tr -d '\n')"
    else
        echo "Config file not found: $DL_CONF"
    fi

    echo ""
    echo "Hyprland active monitors:"
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null | sed 's/^/  /' || echo "  (Hyprland not running)"
}

# ── Read current $DL value from config ───────────────────────────────────────
current_dl() {
    grep -oP '^\$DL\s*=\s*\K.*' "$DL_CONF" 2>/dev/null | tr -d '[:space:]' || echo "DVI-I-1"
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    local dry_run="false"
    local status_only="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)   dry_run="true";   shift ;;
            --status)    status_only="true"; shift ;;
            -h|--help)
                echo "Usage: $(basename "$0") [--dry-run] [--status] [--help]"
                exit 0 ;;
            *) error "Unknown option: $1"; exit 1 ;;
        esac
    done

    if [ "$status_only" = "true" ]; then
        show_status
        exit 0
    fi

    info "Detecting connected EVDI DVI port..."

    detected=$(detect_evdi_port) || true

    if [ -z "$detected" ]; then
        error "No connected EVDI DVI port found."
        echo ""
        echo "  Suggestions:"
        echo "    • Check that the DisplayLink adapter is plugged in"
        echo "    • Run 'dmesg | grep -i evdi' for kernel module status"
        echo "    • Run 'rc-service displaylink start' to start the service"
        echo "    • Run toggle_ext_monitors.sh to start DisplayLink first"
        echo ""
        echo "  Use '$(basename "$0") --status' to see all EVDI ports."
        exit 1
    fi

    info "Detected: ${detected}"

    local cur
    cur=$(current_dl)

    if [ "$detected" = "$cur" ]; then
        info "Config already set to ${detected}. Reloading Hyprland anyway..."
        if [ "$dry_run" = "false" ]; then
            hyprctl reload 2>/dev/null || true
            sleep 1
            # Move workspaces to the detected monitor
            for ws in 4 5 6; do
                hyprctl dispatch moveworkspacetomonitor "${ws} ${detected}" 2>/dev/null || true
            done
        fi
        exit 0
    fi

    info "Updating: $DL  →  ${detected}"

    if [ "$dry_run" = "true" ]; then
        warn "Dry-run mode — no changes made."
        info "[DRY-RUN] Would write '\$DL = ${detected}' to ${DL_CONF}"
        info "[DRY-RUN] Would run: hyprctl reload"
        exit 0
    fi

    # Update the variable file
    echo "\$DL = ${detected}" > "$DL_CONF"
    info "Config updated: \$DL = ${detected}"

    # Reload Hyprland
    hyprctl reload 2>/dev/null || true
    info "Hyprland config reloaded."
    sleep 1

    # Move workspaces to the detected monitor
    for ws in 4 5 6; do
        hyprctl dispatch moveworkspacetomonitor "${ws} ${detected}" 2>/dev/null || true
    done

    notify-send "DisplayLink Hotplug" "Monitor activated on ${detected}" 2>/dev/null || true
    info "Done! Workspaces 4-6 → ${detected}"
}

main "$@"
