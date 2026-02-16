#!/bin/sh
# elogind sleep hook для управления мониторами при suspend/resume
# Установить в: /etc/elogind/system-sleep/hyprlock-monitors
# Права: chmod +x /etc/elogind/system-sleep/hyprlock-monitors

case ${1-} in
pre)
	# Выполняется перед suspend - выключаем все мониторы
	hyprctl keyword monitor "DVI-I-1,disable" 2>/dev/null
	hyprctl keyword monitor "HDMI-A-1,disable" 2>/dev/null
	hyprctl dispatch dpms off 2>/dev/null
	;;
# run in background given resume is flaky if elogind did not finish
post)
	hyprctl dispatch dpms on 2>/dev/null &
	sleep 0.5
	hyprctl keyword monitor "DVI-I-1, 1920x1080@75, 0x0, 1.00" 2>/dev/null &
	hyprctl keyword monitor "HDMI-A-1, 1920x1080@75, 1920x0, 1.00" 2>/dev/null &
	;;
*)
	exit 1
	;;
esac

exit 0
