#!/bin/bash
# Перенос хоткеев Hyprland -> GNOME (gsettings). Идемпотентен.
# Источник: ~/.config/hypr/hyprland/keybinds.conf ($mainMod = SUPER)
# Сгенерирован: 2026-10-07
set -euo pipefail

export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"

WM=org.gnome.desktop.wm.keybindings
SH=org.gnome.shell.keybindings
MK=org.gnome.settings-daemon.plugins.media-keys
PREFS=org.gnome.desktop.wm.preferences

# --- 1. Оконные биндинги ---
gsettings set $WM close "['<Alt>F4', '<Super>q']"          # Super+Q killactive
gsettings set $WM toggle-fullscreen "['<Super>f']"          # Super+F fullscreen

# --- 2. Workspaces: статические 10 ---
gsettings set $PREFS num-workspaces 10
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings set $WM switch-to-workspace-$i "['<Super>$i']"
  gsettings set $WM move-to-workspace-$i "['<Super><Shift>$i', '<Alt><Shift>$i']"
done
gsettings set $WM switch-to-workspace-10 "['<Super>0']"
gsettings set $WM move-to-workspace-10 "['<Super><Shift>0', '<Alt><Shift>0']"

# --- 3. Биндинги шелла (добавляем к нативным, не затирая) ---
add_binding() { # schema key binding
  local cur; cur=$(gsettings get "$1" "$2")
  [[ "$cur" == "@as []" ]] && cur="[]"
  cur="${cur#\[}"; cur="${cur%\]}"
  [[ "$cur" == *"$3"* ]] && return 0
  if [[ -z "$cur" ]]; then gsettings set "$1" "$2" "[\"$3\"]"
  else gsettings set "$1" "$2" "[$cur, \"$3\"]"; fi
}
add_binding $SH toggle-application-view "<Super>d"   # Super+D лаунчер приложений
add_binding $SH toggle-quick-settings   "<Super>n"   # Super+N control center

# --- 4. Кастомные запуски ---
BASE="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
DIR="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"
# slug|name|command|binding
CB=(
  "custom0|Terminal (kitty)|kitty|<Super>Return"
  "custom1|Terminal (kitty)|kitty|<Super>t"
  "custom2|Files (thunar)|thunar|<Super>e"
  "custom3|Settings|gnome-control-center|<Super><Ctrl>d"
  "custom4|Session menu|gnome-session-quit --power-off|<Super><Shift>e"
  "custom5|Browser (zen)|zen|<Super>F1"
  "custom6|Mail (thunderbird)|thunderbird|<Super>F2"
  "custom7|Editor (geany)|geany|<Super>F4"
  "custom8|GParted|gparted|<Super>F6"
  "custom9|Meld|meld|<Super>F9"
  "custom10|Calculator|galculator|<Super>F12"
  "custom11|Toggle night light|sh -c 'g=\$(gsettings get org.gnome.settings-daemon.plugins.color night-light-enabled); if [ \"\$g\" = true ]; then v=false; else v=true; fi; gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled \$v'|<Super>b"
)

paths=""
for e in "${CB[@]}"; do
  IFS='|' read -r slug name cmd bind <<<"$e"
  paths+="'${DIR}${slug}/', "
done
gsettings set $MK custom-keybindings "[${paths%, }]"

for e in "${CB[@]}"; do
  IFS='|' read -r slug name cmd bind <<<"$e"
  p="${BASE}:${DIR}${slug}/"
  gsettings set "$p" name "$name"
  gsettings set "$p" command "$cmd"
  gsettings set "$p" binding "$bind"
done

echo "OK: перенос применён."
