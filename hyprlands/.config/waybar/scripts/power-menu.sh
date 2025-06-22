#!/usr/bin/env bash

config="$HOME/.config/rofi/power-menu.rasi"

actions=$(echo -e "  Lock\n   Shutdown\n   Reboot\n   Suspend\n   Hibernate\n 󰞘  Logout")

# Display logout menu
selected_option=$(echo -e "$actions" | rofi -dmenu -i -config "${config}" || pkill -x rofi)

# Perform actions based on the selected option
case "$selected_option" in
*Lock)
	loginctl lock-session
	;;
*Shutdown)
	loginctl poweroff
	;;
*Reboot)
	loginctl reboot
	;;
*Suspend)
	loginctl suspend
	;;
*Hibernate)
	loginctl hibernate
	;;
*Logout)
	loginctl kill-session "$XDG_SESSION_ID"
	;;
esac
