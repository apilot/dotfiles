#!/bin/bash
# Проверочный скрипт для установки управления мониторами
# Запустить: bash check-setup.sh

echo "=== Проверка установки управления мониторами ==="
echo ""

# 1. Проверка скриптов
echo "1. Проверка скриптов:"
ls -la ~/.config/hypr/scripts/ | grep -E "(lock|suspend|sleep|elogind)" || echo "   (скрипты не найдены)"
echo ""

# 2. Проверка elogind hook
echo "2. Проверка elogind hook:"
if [ -f "/etc/elogind/system-sleep/hyprlock-monitors" ]; then
	echo "✅ Hook установлен: /etc/elogind/system-sleep/hyprlock-monitors"
	ls -la /etc/elogind/system-sleep/hyprlock-monitors
else
	echo "❌ Hook не установлен!"
	echo "   Выполните:"
	echo "   cd ~/.config/hypr/scripts && sudo bash install-elogind-hook.sh"
fi
echo ""

# 3. Проверка всех elogind hooks
echo "3. Все установленные elogind hooks:"
if [ -d "/etc/elogind/system-sleep" ]; then
	ls -la /etc/elogind/system-sleep/ 2>/dev/null || echo "   (пусто или нет прав)"
else
	echo "   Директория /etc/elogind/system-sleep/ не существует"
fi
echo ""

# 4. Проверка статуса мониторов
echo "4. Текущий статус мониторов:"
hyprctl monitors all
echo ""

# 5. Проверка elogind сервиса
echo "5. Статус elogind:"
rc-status 2>/dev/null | grep -i elogind || echo "   (elogind не найден в rc-status)"
echo ""

echo "=== Проверка завершена ==="
