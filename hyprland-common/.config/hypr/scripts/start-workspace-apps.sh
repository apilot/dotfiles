#!/bin/bash
# Launch commonly used apps on specific Hyprland workspaces
# Switches to target workspace, launches app, restores original workspace
# Keybind: $mainMod SHIFT+S
#
# Hyprland 0.55 + Lua config: 'hyprctl dispatch workspace N' is gone (it is now
# Lua-evaluated). Use 'hyprctl dispatch "hl.dsp.focus({workspace=\"N\"})"'.
# Apps are launched directly (&) — the script already runs inside the session.

# Focus a workspace by id via the native Lua dispatcher.
ws_focus() { hyprctl dispatch "hl.dsp.focus({workspace=\"$1\"})" >/dev/null 2>&1; }

# Save current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r .id)

# Workspace 1 — eDP-1 (Messaging)
ws_focus 1
telegram-desktop &
'/opt/brave.com/brave/brave-browser' --profile-directory=Default --app-id=minhipnfhcajoikccdhkljhjhklnbpio &
sleep 0.5

# Workspace 2 — eDP-1 (Work browser)
ws_focus 2
zen -P work --new-instance &
sleep 0.5

# Workspace 3 — eDP-1 (Mail & Calendar)
ws_focus 3
geary &
gnome-calendar &
sleep 0.5

# Workspace 4 — DisplayLink (Terminals)
ws_focus 4
kitty &
kitty &
sleep 0.5

# Workspace 5 — DisplayLink (Security)
ws_focus 5
/opt/Bitwarden/bitwarden &
sleep 0.5

# Workspace 7 — HDMI-A-1 (Browser)
ws_focus 7
zen &
sleep 0.5

# Workspace 8 — HDMI-A-1 (Notes)
ws_focus 8
obsidian &
sleep 0.5

# Restore original workspace
ws_focus "$CURRENT_WS"
