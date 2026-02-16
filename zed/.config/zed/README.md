# Zed Editor Configuration - Neovim LazyVim Edition

Эта конфигурация портирует ключевые особенности, хоткейсы и поведение из **Neovim LazyVim** в **Zed Editor**, обеспечивая согласованный и комфортный рабочий процесс в обоих редакторах.

## 🎯 Особенности

- ✅ **Vim Mode** - Полная поддержка vim mode (как в nvim)
- ✅ **Space as Leader** - Space используется как лидер-клавиша (как в LazyVim)
- ✅ **Relative Line Numbers** - Относительные номера строк (как в nvim)
- ✅ **LSP Integration** - Полная интеграция LSP с похожими хоткеями
- ✅ **Git Integration** - LazyGit интеграция через floating terminal
- ✅ **Fzf-style Search** - Поиск файлов и содержимого через fzf + ripgrep
- ✅ **Format on Save** - Автоматическое форматирование при сохранении
- ✅ **Inlay Hints** - Подсказки типов (как в nvim)
- ✅ **Catppuccin Theme** - Тема Catppuccin (как в nvim)

## 📦 Установка

### Автоматическая установка

```bash
# Запустите установочный скрипт
cd ~/.config/zed
./install.sh
```

### Ручная установка

1. **Убедитесь, что установлены зависимости:**
   ```bash
   # Gentoo
   emerge app-misc/fzf app-text/bat sys-apps/ripgrep x11-terms/kitty

   # Ubuntu/Debian
   apt install fzf bat ripgrep kitty

   # Arch
   pacman -S fzf bat ripgrep kitty
   ```

2. **Создайте символическую ссылку:**
   ```bash
   ln -s ~/dotfiles/zed/.config/zed ~/.config/zed
   ```

3. **Перезапустите Zed Editor**

## ⌨️ Основные хоткеи

### 🎹 Leader Key
**Space** - основной лидер-кей (как в LazyVim)

### 📁 Файлы (leader+f)
| Хоткей | Действие |
|--------|----------|
| `Space Space` | Найти файлы |
| `Space f f` | Найти файлы |
| `Space f g` | Live grep (поиск по содержимому) |
| `Space f r` | Недавние файлы |
| `Space f c` | Команды |

### 🌿 Git (leader+g)
| Хоткей | Действие |
|--------|----------|
| `Space g g` | Lazygit |
| `Space g s` | Git status |
| `Space g c` | Git commit |
| `Space g p` | Git push |

### 💻 LSP (leader+l)
| Хоткей | Действие |
|--------|----------|
| `Space l f` | Форматировать |
| `Space l n` | Переименовать символ |
| `Space l a` | Code actions |
| `Space l d` | Go to definition |
| `Space l i` | Go to implementation |
| `Space l r` | Find all references |

### 🪟 Окна (leader+w)
| Хоткей | Действие |
|--------|----------|
| `Space w e` | Выровнять окна |
| `Space w v` | Разделить вертикально |
| `Space w h` | Разделить горизонтально |
| `Space w q` | Закрыть окно |

### 🎯 Навигация
| Хоткей | Действие |
|--------|----------|
| `Ctrl+h` | Левое окно |
| `Ctrl+j` | Нижнее окно |
| `Ctrl+k` | Верхнее окно |
| `Ctrl+l` | Правое окно |

### ⚡ Быстрые действия
| Хоткей | Действие |
|--------|----------|
| `Space w` | Сохранить файл |
| `Space q` | Закрыть файл |
| `Space Q` | Выйти из Zed |
| `Space e` | Файловый менеджер |

### 🚀 Терминал (leader+t)
| Хоткей | Действие |
|--------|----------|
| `Space t t` | Открыть/закрыть терминал |

## 📋 Сравнение с Neovim LazyVim

### Настройки редактора

| Настройка | Neovim | Zed |
|-----------|--------|-----|
| Vim mode | ✅ | ✅ |
| Relative line numbers | ✅ | ✅ |
| Tab size: 2 | ✅ | ✅ |
| Expand tabs | ✅ | ✅ |
| Cursor line highlight | ✅ | ✅ |
| System clipboard | ✅ | ✅ |
| Format on save | ✅ | ✅ |
| Inlay hints | ✅ | ✅ |
| Git gutter | ✅ | ✅ |
| Inline blame | ✅ | ✅ |

### Хоткеи

| Категория | Neovim | Zed |
|-----------|--------|-----|
| Files (leader+f) | ✅ | ✅ |
| Git (leader+g) | ✅ | ✅ |
| LSP (leader+l) | ✅ | ✅ |
| Windows (leader+w) | ✅ | ✅ |
| Terminal (leader+t) | ✅ | Частично |
| UI toggles (leader+u) | ✅ | Частично |
| Code (leader+c) | ✅ | Частично |
| Tests (leader+t) | ✅ | ❌ (через плагины) |
| Rails (leader+r) | ✅ | ❌ (через LSP) |

## 🔧 Конфигурационные файлы

### settings.json
Основные настройки редактора, портированные из `~/.config/nvim/lua/config/editor.lua`:
- Vim mode
- Relative line numbers
- Tab size и indentation
- LSP settings
- Git integration
- Theme settings

### keymap.json
Хоткеи, портированные из `~/.config/nvim/lua/config/keymaps.lua`:
- Space как leader key
- File operations (leader+f)
- Git operations (leader+g)
- LSP operations (leader+l)
- Window management (leader+w)
- Terminal toggle (leader+tt)
- Quick save/quit (leader+w/q)

### tasks.json
Задачи для интеграции с внешними инструментами:
- LazyGit через floating kitty terminal
- Fzf-style file search
- Live grep через ripgrep
- Recent files
- Git files

## 📚 Полная документация

См. `KEYMAP_REFERENCE.md` для полной справки по хоткеям и сравнению с Neovim.

## 🆘 Troubleshooting

### Хоткеи не работают
1. Убедитесь, что vim mode включен в settings.json
2. Проверьте, что нет конфликтующих хоткеев в других конфигурациях
3. Перезапустите Zed Editor

### Fzf/ripgrep не работают
1. Убедитесь, что fzf и ripgrep установлены
2. Проверьте PATH в Zed терминале
3. Проверьте задачи в tasks.json

### LazyGit не открывается
1. Убедитесь, что lazygit установлен
2. Убедитесь, что kitty установлен
3. Проверьте задачу "lazygit" в tasks.json

## 🔗 Полезные ссылки

- [Zed Documentation](https://zed.dev/docs/)
- [Zed Keybindings](https://zed.dev/docs/key-bindings)
- [LazyVim Documentation](https://www.lazyvim.org/)
- [Neovim Documentation](https://neovim.io/doc/)

## 📝 Примечания

- Не все функции Neovim имеют прямые аналоги в Zed (например, Undotree, Twilight, Neotest)
- Некоторые Ruby/Rails специфичные функции заменены на LSP функциональность
- Zed имеет встроенные функции, которых нет в nvim (AI Assistant, Collaboration Panel)

## 🤝 Contributing

Если вы хотите улучшить эту конфигурацию:
1. Создайте fork репозитория
2. Внесите изменения
3. Отправьте pull request

## 📄 License

Эта конфигурация распространяется свободно. Модифицируйте её по своему усмотрению.

---

**Создано на основе конфигурации Neovim LazyVim от `/home/aboyarinov/.config/nvim`**
