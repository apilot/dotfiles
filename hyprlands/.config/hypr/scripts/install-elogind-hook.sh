#!/bin/bash
# Установочный скрипт для elogind sleep hook
# Запустить: sudo bash ./install-elogind-hook.sh

HOOK_NAME="hyprlock-monitors"
HOOK_SOURCE="$HOME/.config/hypr/scripts/elogind-sleep-hook.sh"
HOOK_DEST="/etc/elogind/system-sleep/$HOOK_NAME"

echo "Установка elogind sleep hook для управления мониторами..."
echo ""

# Проверка что исходный файл существует
if [ ! -f "$HOOK_SOURCE" ]; then
	echo "ОШИБКА: Исходный файл не найден: $HOOK_SOURCE"
	exit 1
fi

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
	echo "ОШИБКА: Этот скрипт должен быть запущен с sudo"
	echo "Используйте: sudo bash $0"
	exit 1
fi

# Создание директории если её нет
if [ ! -d "/etc/elogind/system-sleep" ]; then
	echo "Создание директории: /etc/elogind/system-sleep"
	mkdir -p /etc/elogind/system-sleep
fi

# Копирование файла
echo "Копирование: $HOOK_SOURCE -> $HOOK_DEST"
cp "$HOOK_SOURCE" "$HOOK_DEST"

# Установка прав на выполнение
echo "Установка прав на выполнение..."
chmod +x "$HOOK_DEST"

# Проверка результата
if [ -f "$HOOK_DEST" ]; then
	echo ""
	echo "✅ Успешно установлено!"
	echo "   Hook: $HOOK_DEST"
	echo "   Права: $(ls -l "$HOOK_DEST" | awk '{print $1}')"
	echo ""
	echo "Теперь при suspend/resume мониторы будут управляться автоматически."
	echo ""
	echo "Для проверки установленных hooks:"
	echo "  ls -la /etc/elogind/system-sleep/"
	echo ""
else
	echo ""
	echo "❌ ОШИБКА: Файл не был скопирован"
	exit 1
fi
