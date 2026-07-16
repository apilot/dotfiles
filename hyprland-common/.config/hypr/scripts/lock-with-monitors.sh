#!/bin/bash
# Скрипт для блокировки экрана с управлением мониторами
# Отключает внешние мониторы перед блокировкой, включает обратно после разблокировки

# Список внешних мониторов (кроме eDP-1)
EXTERNAL_MONITORS=("DVI-I-1" "HDMI-A-1")

# Функция для отключения внешних мониторов
disable_external_monitors() {
	for monitor in "${EXTERNAL_MONITORS[@]}"; do
		hyprctl keyword monitor "$monitor,disable" 2>/dev/null
	done
}

# Функция для включения внешних мониторов
enable_external_monitors() {
	# Включаем DVI-I-1
	hyprctl keyword monitor "DVI-I-1, 1920x1080@75, 0x0, 1.00" 2>/dev/null
	# Включаем HDMI-A-1
	hyprctl keyword monitor "HDMI-A-1, 1920x1080@75, 1920x0, 1.00" 2>/dev/null
}

# Отключаем внешние мониторы перед блокировкой
disable_external_monitors

# Ждем небольшую задержку для уверенности, что мониторы отключились
sleep 0.5

# Запускаем hyprlock и ждем его завершения
hyprlock

# После разблокировки включаем мониторы обратно
enable_external_monitors
