# Настройка управления мониторами для Hyprland и Hyprlock (OpenRC + elogind)

## 📋 Что было сделано

### 1. ✅ Исправлен lock-with-monitors.sh
- Исправлена синтаксическая ошибка в команде отключения мониторов
- Было: `"monitor, disable"` → Стало: `"monitor,disable"` (без пробела)

### 2. ✅ Создан elogind-sleep-hook.sh
- elogind sleep hook для автоматического управления мониторами при suspend/resume
- Работает с OpenRC (не требует systemd)
- Формат совместим с elogind (аргументы pre/post)

### 3. ✅ Создан install-elogind-hook.sh
- Установочный скрипт для копирования hook в правильное место
- Автоматически устанавливает права на выполнение

### 4. ✅ Обновлен sleep.sh
- Заменен swayidle на нативную реализацию с loginctl
- Теперь использует hyprlock вместо swaylock
- Добавлена логика управления яркостью и suspend

### 5. ✅ Исправлены права доступа
- lock.sh теперь исполняемый
- Все новые скрипты имеют правильные права доступа

---

## 🎯 Ожидаемое поведение

### При блокировке экрана (SUPER+SHIFT+L):
1. Все внешние мониторы (DVI-I-1, HDMI-A-1) отключаются
2. Включается только встроенный монитор eDP-1
3. Запускается hyprlock
4. После ввода правильного пароля все мониторы включаются обратно

### При suspend (режим ожидания):
1. Все мониторы выключаются (dpms off + external monitors disabled)
2. При resume все мониторы включаются обратно (dpms on + external monitors enabled)

### При idle (простое):
- Через 160 сек - уменьшение яркости на 50%
- Через 300 сек - блокировка экрана с hyprlock
- Через 600 сек - suspend системы

---

## 📦 Установка (OpenRC + elogind)

### Обязательная установка elogind sleep hook (требует sudo):

**Вариант 1: Автоматическая установка:**
```bash
cd ~/.config/hypr/scripts
sudo bash install-elogind-hook.sh
```

**Вариант 2: Ручная установка:**
```bash
# Создание директории если её нет
sudo mkdir -p /etc/elogind/system-sleep

# Копирование hook скрипта
sudo cp ~/.config/hypr/scripts/elogind-sleep-hook.sh /etc/elogind/system-sleep/hyprlock-monitors

# Установка прав на выполнение
sudo chmod +x /etc/elogind/system-sleep/hyprlock-monitors

# Проверка
ls -la /etc/elogind/system-sleep/
```

### Проверка установленных hooks:
```bash
# Посмотреть все elogind sleep hooks
ls -la /etc/elogind/system-sleep/

# Должен быть виден:
# -rwxr-xr-x 1 root root ... hyprlock-monitors
# -rwxr-xr-x 1 root root ... nvidia (если есть NVIDIA)
```

### Опционально: Автозапуск sleep.sh

Добавьте в `~/.config/hypr/hyprland.conf`:
```bash
exec-once = ~/.config/hypr/scripts/sleep.sh &
```

---

## 🧪 Тестирование

### 1. Тест блокировки экрана:
```bash
~/.config/hypr/scripts/lock-with-monitors.sh
```
- Нажмите Enter или Esc для выхода без пароля
- Или введите пароль для разблокировки

### 2. Тест elogind sleep hook:
```bash
# Проверить что hook установлен
ls -la /etc/elogind/system-sleep/

# Протестировать вручную (не требуется при установленном hook)
~/.config/hypr/scripts/elogind-sleep-hook.sh pre
~/.config/hypr/scripts/elogind-sleep-hook.sh post
```

### 3. Тест suspend/resume:
```bash
# Запустить suspend
loginctl suspend

# После resume проверьте что все мониторы включены
hyprctl monitors all
```

### 4. Тест хоткея:
- Нажмите `SUPER+SHIFT+L`
- Проверьте что включен только eDP-1: `hyprctl monitors all`
- Введите пароль для разблокировки
- Проверьте что все мониторы включены снова

### 5. Проверка статуса мониторов:
```bash
hyprctl monitors all
```

---

## 📝 Конфигурация мониторов

Ваши мониторы:
- **eDP-1** - встроенный (1920x1080@240Hz, основной)
- **DVI-I-1** - внешний Iiyama PL2493H #1 (1920x1080@75Hz)
- **HDMI-A-1** - внешний Iiyama PL2493H #2 (1920x1080@75Hz)

---

## ⚙️ Настройка конфигурации

### В hyprland.conf (строка 371):
```bash
bind = $mainMod SHIFT, L, exec, ~/.config/hypr/scripts/lock-with-monitors.sh
```

### В hyprlock.conf:
Все элементы (background, labels, input-field) привязаны к `monitor = eDP-1`

---

## 🔧 Возможные проблемы и решения

### Проблема: Хоткей SUPER+SHIFT+L не работает
**Решение:**
1. Проверьте что скрипт имеет права выполнения:
   ```bash
   ls -la ~/.config/hypr/scripts/lock-with-monitors.sh
   ```
2. Перезагрузите конфигурацию Hyprland:
   ```bash
   SUPER+SHIFT+R
   ```

### Проблема: Мониторы не включаются после resume
**Решение:**
1. Проверьте что hook установлен:
   ```bash
   ls -la /etc/elogind/system-sleep/
   ```
2. Проверьте права на выполнение:
   ```bash
   ls -la /etc/elogind/system-sleep/hyprlock-monitors
   ```
3. Проверьте логи:
   ```bash
   journalctl -xe -u elogind
   ```
4. Протестируйте hook вручную:
   ```bash
   sudo /etc/elogind/system-sleep/hyprlock-monitors post
   ```

### Проблема: Hook не работает при suspend
**Решение:**
1. Убедитесь что elogind активен:
   ```bash
   rc-status | grep elogind
   ```
2. Проверьте конфигурацию elogind:
   ```bash
   cat /etc/elogind/logind.conf
   cat /etc/elogind/sleep.conf
   ```

### Проблема: systemctl не найден (это нормально для OpenRC)
**Решение:**
Используйте loginctl вместо systemctl:
```bash
# Для suspend
loginctl suspend

# Для проверки статуса
loginctl list-sessions
```

---

## 📚 Полезные команды

### Управление мониторами:
```bash
# Показать все мониторы
hyprctl monitors all

# Отключить конкретный монитор
hyprctl keyword monitor "HDMI-A-1,disable"

# Включить монитор с настройкой
hyprctl keyword monitor "HDMI-A-1, 1920x1080@75, 1920x0, 1.00"

# Выключить все мониторы (dpms)
hyprctl dispatch dpms off

# Включить все мониторы (dpms)
hyprctl dispatch dpms on
```

### Управление Hyprland:
```bash
# Перезагрузить конфигурацию Hyprland
hyprctl reload

# Перезагрузить конфигурацию с хоткеем
SUPER+SHIFT+R
```

### Управление suspend (elogind):
```bash
# Suspend системы
loginctl suspend

# Проверить состояние
loginctl
```

### OpenRC сервисы:
```bash
# Статус всех сервисов
rc-status

# Статус elogind
rc-status elogind

# Перезапустить elogind (требует sudo)
sudo rc-service elogind restart
```

---

## 🎨 Файлы которые были созданы/изменены

### Измененные:
- `~/.config/hypr/scripts/lock-with-monitors.sh` - исправлен синтаксис
- `~/.config/hypr/scripts/sleep.sh` - полностью обновлен

### Новые:
- `~/.config/hypr/scripts/elogind-sleep-hook.sh` - elogind sleep hook (для установки в /etc/elogind/system-sleep/)
- `~/.config/hypr/scripts/install-elogind-hook.sh` - установочный скрипт
- `~/.config/hypr/README_MONITOR_SETUP.md` - этот файл (документация для OpenRC)

### Права доступа:
- `chmod +x ~/.config/hypr/scripts/lock.sh` - теперь исполняемый
- Все новые скрипты уже имеют права `+x`

### Устаревшие (удалены):
- `~/.config/hypr/scripts/hyprlock-suspend-hook.sh` - systemd hook (не нужен для OpenRC)
- `~/.config/systemd/system/hyprlock-suspend.service` - systemd service (не нужен для OpenRC)

---

## 📞 Поддержка

Если возникают проблемы:
1. Проверьте что hook установлен в `/etc/elogind/system-sleep/`
2. Проверьте права на выполнение: `ls -la /etc/elogind/system-sleep/`
3. Проверьте логи elogind: `journalctl -xe -u elogind`
4. Проверьте синтаксис скриптов: `bash -n script.sh`
5. Протестируйте каждый скрипт отдельно
6. Обратитесь к документации Hyprland и Hyprlock

---

## 🎓 Дополнительная информация

### Почему используются разные скрипты?

1. **lock-with-monitors.sh** - для ручной блокировки экрана (SUPER+SHIFT+L)
2. **elogind-sleep-hook.sh** - для автоматического управления при suspend/resume (устанавливается в /etc/elogind/system-sleep/)
3. **sleep.sh** - для автоматического управления при idle (опционально)

### OpenRC vs systemd

Ваша система использует:
- **OpenRC** - система инициализации (вместо systemd)
- **elogind** - logind сервис (предоставляет функции systemd-logind)
- **loginctl** - команда для управления сессиями и suspend

Поэтому systemd-sleep hooks не работают, нужно использовать elogind sleep hooks.

### Почему не используется swayidle?

- swayidle заменен на нативную реализацию для лучшей совместимости с Hyprland
- Используется loginctl для управления suspend
- Это позволяет использовать hyprlock вместо swaylock

### Где хранятся elogind sleep hooks?

**Системные hooks:** `/usr/lib/elogind/system-sleep/`
- Пример: nvidia hook

**Локальные hooks:** `/etc/elogind/system-sleep/`
- Наш hook должен быть установлен сюда
- Преимущество: локальные hooks могут быть изменены пользователем

---

## 🔍 Проверка установки

После установки выполните эту проверку:

```bash
#!/bin/bash
echo "=== Проверка установки управления мониторами ==="
echo ""

# 1. Проверка скриптов
echo "1. Проверка скриптов:"
ls -la ~/.config/hypr/scripts/ | grep -E "(lock|suspend|sleep)"
echo ""

# 2. Проверка elogind hook
echo "2. Проверка elogind hook:"
if [ -f "/etc/elogind/system-sleep/hyprlock-monitors" ]; then
    echo "✅ Hook установлен: /etc/elogind/system-sleep/hyprlock-monitors"
    ls -la /etc/elogind/system-sleep/hyprlock-monitors
else
    echo "❌ Hook не установлен!"
    echo "   Выполните: cd ~/.config/hypr/scripts && sudo bash install-elogind-hook.sh"
fi
echo ""

# 3. Проверка статуса мониторов
echo "3. Текущий статус мониторов:"
hyprctl monitors all
echo ""

# 4. Проверка elogind
echo "4. Статус elogind:"
rc-status | grep elogind
echo ""

echo "=== Проверка завершена ==="
```

Сохраните этот скрипт как `check-setup.sh` и выполните:
```bash
chmod +x check-setup.sh
bash check-setup.sh
```

---

**Создано:** 2026-02-01
**Версия:** 1.0 (OpenRC + elogind)
**Система:** Gentoo Linux с OpenRC
