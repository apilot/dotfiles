#!/bin/bash
# Скрипт для управления мониторами при suspend/resume
# Вызывается systemd service при suspend и resume

# Определяем режим работы (suspend или resume)
MODE="$1"

# Список внешних мониторов (кроме eDP-1)
EXTERNAL_MONITORS=("DVI-I-1" "HDMI-A-1")

case "$MODE" in
pre)
	# Выполняется перед suspend - выключаем все мониторы
	for monitor in "${EXTERNAL_MONITORS[@]}"; do
		hyprctl keyword monitor "$monitor,disable" 2>/dev/null
	done
	hyprctl dispatch dpms off 2>/dev/null
	;;
post)
	# Выполняется после resume - включаем все мониторы
	# Сначала включаем eDP-1
	hyprctl dispatch dpms on 2>/dev/null
	sleep 0.5
	# Затем включаем внешние мониторы
	hyprctl keyword monitor "DVI-I-1, 1920x1080@75, 0x0, 1.00" 2>/dev/null
	hyprctl keyword monitor "HDMI-A-1, 1920x1080@75, 1920x0, 1.00" 2>/dev/null
	;;
*)
	echo "Usage: $0 {pre|post}"
	exit 1
	;;
esac

exit 0
