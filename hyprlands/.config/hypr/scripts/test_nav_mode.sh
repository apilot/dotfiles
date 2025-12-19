#!/bin/bash

# Test script for navigation mode
echo "Testing Navigation Mode Configuration"
echo "===================================="

echo ""
echo "Current mainMod definition:"
grep "\$mainMod = " ~/.config/hypr/hyprland.conf

echo ""
echo "Current navigation mode:"
cd "$(dirname "$0")"
./set_nav_mode.sh status

echo ""
echo "Checking SUPER_L bindings:"
hyprctl binds | grep -A 2 -B 2 "modmask: 64.*key: [HJKL;]" || echo "No SUPER_L HJKL/semicolon bindings found"

echo ""
echo "Checking arrow key bindings (should always work):"
hyprctl binds | grep -A 1 "modmask: 64.*key: [lrud]" | head -8

echo ""
echo "Controls:"
echo "  Super + ;        - Toggle navigation modes"
echo "  Super + Shift + ; - Force standard mode"
echo "  Super + Ctrl + ;  - Show current mode"
echo ""
echo "Arrow keys (Super + ←→↑↓) should always work as fallback."
echo ""
echo "Basic Super commands should now work:"
echo "  Super + 1-9      - Switch workspaces"
echo "  Super + T        - Open terminal"
echo "  Super + Q        - Close window"