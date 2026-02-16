# Which-Key в Zed Editor

Эта страница описывает функциональность **which-key** в Zed Editor, аналогичную плагину `folke/which-key.nvim` из Neovim.

## 🎯 Что такое Which-Key?

**Which-Key** - это всплывающее окно, которое показывает доступные привязки клавиш после нажатия лидер-клавиши или любой другой комбинации.

## ✅ Встроенная функциональность Zed

Zed Editor имеет **встроенную which-key функциональность**, которая включена в вашей конфигурации:

```json
"which_key": {
  "enabled": true,
  "delay_ms": 0,
  "max_width_chars": 50
}
```

### Как использовать:

1. Нажмите **Space** (лидер-клавиша) в vim mode
2. Подождите мгновение (или `delay_ms: 0` для мгновенного показа)
3. Появится popup со всеми доступными привязками

## 🎹 Дополнительная справка

Помимо встроенной which-key, у вас есть дополнительные способы посмотреть привязки:

### 1. Интерактивная справка (fzf)
**Хоткей:** `Space ?` или `Space /`

Открывает интерактивное меню со всеми привязками через fzf:

```bash
# Запуск вручную
~/.config/zed/which-key-fzf.sh
```

### 2. Статическая справка ( терминал )
```bash
# Запуск вручную
~/.config/zed/which-key.sh
```

### 3. Командная палитра Zed
**Хоткей:** `Ctrl+Shift+P`

Показывает все доступные команды Zed с поиском.

## 📋 Сравнение с Neovim which-key.nvim

| Функция | Neovim which-key.nvim | Zed Editor |
|---------|----------------------|------------|
| Popup после leader | ✅ | ✅ (встроенный) |
| Группировка по категориям | ✅ | ✅ |
| Описания привязок | ✅ | ✅ |
| Кастомные описания | ✅ | Ограничено |
| Иконки/EMOJI | ✅ | ❌ |
| Интеграция с плагинами | ✅ | Ограничено |
| Многоуровневые меню | ✅ | ✅ |
| Задержка показа | Настраиваемая | Настраиваемая |

## 🔧 Настройка

### Изменить задержку показа

В `settings.json`:

```json
"which_key": {
  "enabled": true,
  "delay_ms": 500,  // Показывать через 0.5 секунды
  "max_width_chars": 60
}
```

### Мгновенный показ

```json
"which_key": {
  "enabled": true,
  "delay_ms": 0  // Мгновенно
}
```

### Отключить

```json
"which_key": {
  "enabled": false
}
```

## 📖 Доступные справки

| Файл | Описание |
|------|----------|
| `~/.config/zed/which-key.sh` | Статическая справка в терминале |
| `~/.config/zed/which-key-fzf.sh` | Интерактивная справка с fzf |
| `~/.config/zed/CHEATSHEET.md` | Быстрая шпаргалка |
| `~/.config/zed/KEYMAP_REFERENCE.md` | Полная документация |

## 🎨 Примеры использования

### Сценарий 1: Новая привязка

Нажимаете `Space g`, но не помните дальше:

**Neovim which-key:**
```
Space g
  g   LazyGit
  s   Git status
  c   Git commit
  p   Git push
```

**Zed which-key:**
```
Shows:
g     LazyGit
s     Toggle Git Focus
c     Toggle Commit Focus
p     Push
```

### Сценарий 2: Изучить LSP привязки

Нажимаете `Space l`:

```
l     Format
n     Rename
a     Code Actions
d     Go to Definition
i     Go to Implementation
r     Find All References
```

## 💡 Советы

1. **Используйте встроенную which-key** для повседневной работы
2. **Используйте `Space ?`** когда нужно быстро найти привязку
3. **Изучите CHEATSHEET.md** для основных привязок
4. **Используйте KEYMAP_REFERENCE.md** для полного сравнения с nvim

## 🔗 Полезные ссылки

- [Which-key menu design discussion](https://github.com/zed-industries/zed/discussions/45181) - Обсуждение which-key в Zed
- [Zed Keybindings Documentation](https://zed.dev/docs/key-bindings) - Официальная документация
- [All Actions Reference](https://zed.dev/docs/all-actions) - Все доступные действия

---

**Sources:**
- [Which-key menu design + customization roadmap](https://github.com/zed-industries/zed/discussions/45181)
- [Keybindings Documentation](https://zed.dev/docs/key-bindings)
