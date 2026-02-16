# Быстрая инструкция по установке elogind hook

## Что нужно сделать:

Для автоматического управления мониторами при suspend/resume нужно установить elogind sleep hook.

## Установка одной командой:

```bash
cd ~/.config/hypr/scripts && sudo bash install-elogind-hook.sh
```

## Вручную (если автоматический не сработал):

```bash
# 1. Создать директорию
sudo mkdir -p /etc/elogind/system-sleep

# 2. Копировать hook
sudo cp ~/.config/hypr/scripts/elogind-sleep-hook.sh /etc/elogind/system-sleep/hyprlock-monitors

# 3. Установить права
sudo chmod +x /etc/elogind/system-sleep/hyprlock-monitors

# 4. Проверить
ls -la /etc/elogind/system-sleep/
```

## После установки:

1. **Тест блокировки экрана:**
   ```bash
   ~/.config/hypr/scripts/lock-with-monitors.sh
   ```
   Нажмите SUPER+SHIFT+L

2. **Тест suspend/resume:**
   ```bash
   loginctl suspend
   ```
   После resume проверьте что все мониторы включены

3. **Проверка установки:**
   ```bash
   bash ~/.config/hypr/scripts/check-setup.sh
   ```

## Если что-то не работает:

- Проверьте права: `ls -la /etc/elogind/system-sleep/`
- Проверьте логи: `journalctl -xe -u elogind`
- Проверьте что elogind запущен: `rc-status | grep elogind`

---

**Готово!** После установки hook будет автоматически управлять мониторами при suspend/resume.
