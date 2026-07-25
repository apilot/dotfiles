#!/bin/bash
# Launch commonly used apps on specific Hyprland workspaces
# Switches to target workspace, launches app, restores original workspace
# Keybind: $mainMod SHIFT+S

# Save current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r .id)

# Workspace 1 — eDP-1 (Messaging)
hyprctl dispatch workspace 1
hyprctl dispatch exec telegram-desktop
hyprctl dispatch exec '/opt/brave.com/brave/brave-browser --profile-directory=Default --app-id=minhipnfhcajoikccdhkljhjhklnbpio'
sleep 0.5

# Workspace 2 — eDP-1 (Work browser)
hyprctl dispatch workspace 2
hyprctl dispatch exec 'zen -P work --new-instance'
sleep 0.5

# Workspace 3 — eDP-1 (Mail & Calendar)
hyprctl dispatch workspace 3
hyprctl dispatch exec geary
hyprctl dispatch exec gnome-calendar
sleep 0.5

# Workspace 4 — DisplayLink (Terminals)
hyprctl dispatch workspace 4
hyprctl dispatch exec kitty
hyprctl dispatch exec kitty
sleep 0.5

# Workspace 5 — DisplayLink (Security)
hyprctl dispatch workspace 5
hyprctl dispatch exec /opt/Bitwarden/bitwarden
sleep 0.5

# Workspace 7 — HDMI-A-1 (Browser)
hyprctl dispatch workspace 7
hyprctl dispatch exec zen
sleep 0.5

# Workspace 8 — HDMI-A-1 (Notes)
hyprctl dispatch workspace 8
hyprctl dispatch exec obsidian
sleep 0.5

# Restore original workspace
hyprctl dispatch workspace "$CURRENT_WS"
