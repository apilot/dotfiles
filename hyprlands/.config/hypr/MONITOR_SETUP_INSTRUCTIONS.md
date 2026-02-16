# Инструкции по установке для управления мониторами

## Что было сделано:

1. ✅ Исправлен lock-with-monitors.sh - убран лишний пробел в команде отключения мониторов
2. ✅ Создан hyprlock-suspend.sh - скрипт для управления мониторами при suspend/resume
3. ✅ Создан hyprlock-suspend-hook.sh - systemd-sleep hook (требует sudo для установки)
4. ✅ Обновлен sleep.sh - заменен swayidle на нативную реализацию с hyprlock
5. ✅ Исправлены права на выполнение для всех скриптов

## Ожидаемое поведение:

### При блокировке экрана (SUPER+SHIFT+L):
- Все внешние мониторы (DVI-I-1, HDMI-A-1) отключаются
- Включается только встроенный монитор eDP-1
- Запускается hyprlock
- После ввода правильного пароля все мониторы включаются обратно

### При suspend (режим ожидания):
- Все мониторы выключаются
- При resume все мониторы включаются обратно

## Установка systemd-sleep hook (ТРЕБУЕТ SUDO):

Для автоматического управления мониторами при suspend/resume нужно создать symlink:

```bash
sudo ln -sf ~/.config/hypr/scripts/hyprlock-suspend-hook.sh /usr/lib/systemd/system-sleep/hyprlock-suspend-hook.sh
```

Если директория не существует:
```bash
sudo mkdir -p /usr/lib/systemd/system-sleep
sudo ln -sf ~/.config/hypr/scripts/hyprlock-suspend-hook.sh /usr/lib/systemd/system-sleep/hyprlock-suspend-hook.sh
```

## Тестирование:

1. Тест блокировки:
   ```bash
   ~/.config/hypr/scripts/lock-with-monitors.sh
   ```
   Нажмите Esc или введите пароль для разблокировки

2. Тест hyprlock-suspend скрипта:
   ```bash
   ~/.config/hypr/scripts/hyprlock-suspend.sh pre
   ~/.config/hypr/scripts/hyprlock-suspend.sh post
   ```

3. Тест хоткея:
   Нажмите SUPER+SHIFT+L

4. Проверка статуса мониторов:
   ```bash
   hyprctl monitors all
   ```

## Дополнительные заметки:

- Если вы используете sleep.sh для автоматического блокирования экрана, он теперь использует hyprlock вместо swaylock
- sleep.sh проверяет idle время и выполняет соответствующие действия
- Для работы sleep.sh требуется loginctl
- Скрипт lock.sh теперь исполняемый и может использоваться отдельно

## Возможные проблемы:

Если systemctl недоступен, sleep.sh использует loginctl для suspend:
```bash
loginctl suspend
```

Если хотите использовать swayidle вместо обновленного sleep.sh, вы можете вернуть оригинальную версию из git или бэкапа.
