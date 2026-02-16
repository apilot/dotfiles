#!/bin/sh
# Управление энергосбережением с использованием hyprlock
# Для работы требуется systemd-inhibit (или запустить с systemd-inhibit)

# Уменьшение яркости через 160 секунд
brightctl_dim() {
    temp=$(brightnessctl g)
    brightnessctl set $((temp / 2))
}

# Восстановление яркости
brightctl_restore() {
    temp=$(brightnessctl g)
    brightnessctl set $((temp * 2))
}

# Блокировка экрана через 300 секунд
lock_screen() {
    # Запускаем hyprlock с управлением мониторами
    $HOME/.config/hypr/scripts/lock-with-monitors.sh
}

# Суспенд системы через 600 секунд
suspend_system() {
    # Используем systemd-inhibit для предотвращения прерывания
    # Можно заменить на loginctl suspend если systemctl не доступен
    if command -v systemctl &> /dev/null; then
        systemctl suspend
    elif command -v loginctl &> /dev/null; then
        loginctl suspend
    fi
}

# Используем цикл для имитации swayidle если swayidle не установлен
while true; do
    sleep 30

    # Проверяем idle время с помощью loginctl
    IDLE_TIME=$(loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p IdleSinceMonotonic --value 2>/dev/null || echo "0")

    # Если idle время больше 160 сек (160000000 микросекунд)
    if [ "$IDLE_TIME" -gt 160000000 ]; then
        brightctl_dim
    fi

    # Если idle время больше 300 сек (300000000 микросекунд)
    if [ "$IDLE_TIME" -gt 300000000 ]; then
        lock_screen
    fi

    # Если idle время больше 600 сек (600000000 микросекунд)
    if [ "$IDLE_TIME" -gt 600000000 ]; then
        suspend_system
        break
    fi
done
