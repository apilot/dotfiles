# Zed Editor - Neovim LazyVim Keymapping Reference

Эта конфигурация портирует хоткейсы из Neovim LazyVim в Zed Editor, чтобы сделать переход между редакторами максимально плавным.

## Leader Key
**Space** - основной лидер-кей (как в nvim)

---

## 📁 Файловые операции (leader+f)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<Space><Space>` | `Space Space` | Найти файлы |
| `<leader>ff` | `Space f f` | Найти файлы |
| `<leader>fg` | `Space f g` | Live grep (поиск по содержимому) |
| `<leader>fb` | `Space f b` | Буферы (следующий) |
| `<leader>fb` | `Space shift-b` | Буферы (предыдущий) |
| `<leader>fc` | `Space f c` | Команды |
| `<leader>fr` | `Space f r` | Недавние файлы |

---

## 🔍 Поиск (leader+s)

| Neovim | Zed | Описание |
|--------|-----|----------|
| N/A | `Space s s` | Поиск по проекту |
| `<leader>fg` | `Space s w` | Live grep (ripgrep) |

---

## 🌿 Git операции (leader+g)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>gg` | `Space g g` | Lazygit |
| `<leader>gs` | `Space g s` | Git status |
| `<leader>gc` | `Space g c` | Git commit |
| `<leader>gp` | `Space g p` | Git push |

---

## 💻 LSP операции (leader+l)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>lf` | `Space l f` | Форматировать |
| `<leader>ln` | `Space l n` | Переименовать символ |
| `<leader>la` | `Space l a` | Code actions |
| `<leader>ld` | `Space l d` | Go to definition |
| `<leader>li` | `Space l i` | Go to implementation |
| `<leader>lr` | `Space l r` | Find all references |
| `<leader>lI` | `Space l shift-i` | LSP info/logs |
| `<leader>lR` | `Space shift-I` | LSP restart |

---

## 🪟 Управление окнами (leader+w)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>we` | `Space w e` | Выровнять окна |
| `<leader>wv` | `Space w v` | Разделить вертикально |
| `<leader>wh` | `Space w h` | Разделить горизонтально |
| `<leader>wq` | `Space w q` | Закрыть окно |

### Навигация между окнами (Ctrl+hjkl - как в nvim)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<C-h>` | `Ctrl+h` | Левое окно |
| `<C-j>` | `Ctrl+j` | Нижнее окно |
| `<C-k>` | `Ctrl+k` | Верхнее окно |
| `<C-l>` | `Ctrl+l` | Правое окно |

---

## 🎨 UI переключатели (leader+u)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>uz` | `Space u z` | Zen mode |
| N/A | `Space u l` | Toggle left dock |
| N/A | `Space u r` | Toggle right dock |
| N/A | `Space u b` | Toggle bottom dock |
| `<leader>ut` | N/A | Twilight (нет в Zed) |

---

## 📝 Буферы (leader+b)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>bb` | `Space b b` | Следующий буфер |
| N/A | `Space shift-b` | Предыдущий буфер |
| N/A | `Space b n` | Следующий буфер |
| N/A | `Space b p` | Предыдущий буфер |
| N/A | `Space b d` | Закрыть буфер |

---

## 🚀 Терминал (leader+t)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>tt` | `Space t t` | Открыть/закрыть терминал |

---

## ⚡ Быстрые действия

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>w` | `Space w` | Сохранить файл |
| `<leader>q` | `Space q` | Закрыть |
| `<leader>Q` | `Space shift-q` | Закрыть все (Quit) |
| `<leader>e` | `Space e` | Файловый менеджер |

---

## 🔧 Код операции (leader+c)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>cf` | `Space c f` | Форматировать |
| `<leader>ca` | `Space c a` | Code actions |
| `<leader>ce` | N/A | Special edit opts |
| `<leader>cc` | N/A | Switch case (vim plugin) |

---

## 🧪 Тестирование (leader+t) - Ruby/Rails специфично

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>tn` | N/A | Run nearest test |
| `<leader>tf` | N/A | Run test file |
| `<leader>ts` | N/A | Run test suite |
| `<leader>to` | N/A | Show test output |

> **Примечание:** В Zed тестирование запускается через встроенный panel или терминал

---

## 🚂 Rails операции (leader+r) - Ruby on Rails специфично

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>rc` | N/A | Goto controller |
| `<leader>rm` | N/A | Goto model |
| `<leader>rv` | N/A | Goto view |
| `<leader>rh` | N/A | Goto helper |
| `<leader>rl` | N/A | Goto locale |
| `<leader>rs` | N/A | Goto server |

> **Примечание:** В Zed используйте LSP (`Space l d`) для навигации

---

## 🤖 AI Assistant (leader+a) - Aider

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>aa` | N/A | Open Aider |
| `<leader>am` | N/A | Add modified files |

> **Примечание:** В Zed используйте встроенный AI Assistant (`Ctrl+Enter`)

---

## 💾 Сессии (leader+S)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>Ss` | N/A | Save session |
| `<leader>Sl` | N/A | Load session |

> **Примечание:** Zed автоматически сохраняет состояние проекта

---

## 🔀 Кодировки (leader+E)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>Ew` | N/A | Windows CP1251 |
| `<leader>Eu` | N/A | UTF-8 |
| `<leader>Ej` | N/A | JSON format (jq) |

> **Примечание:** Zed автоматически определяет кодировку

---

## 📊 CSV операции (leader+C)

| Neovim | Zed | Описание |
|--------|-----|----------|
| `<leader>Cc` | N/A | CSV with comma |
| `<leader>Cs` | N/A | CSV with semicolon |

> **Примечание:** В Zed установите плагин для CSV или используйте расширения

---

## 🎯 Vim Mode Specific

### Insert Mode
| Neovim | Zed | Описание |
|--------|-----|----------|
| N/A | `Ctrl+s` | Сохранить файл |

### Terminal Mode
| Neovim | Zed | Описание |
|--------|-----|----------|
| `<Esc>` | `Escape` | Выйти из терминала |

---

## 📋 Настройки редактора (из nvim)

| Настройка | Neovim | Zed | Статус |
|-----------|--------|-----|--------|
| Vim mode | `vim.cmd` | `vim_mode: true` | ✅ |
| Relative line numbers | `opt.relativenumber` | `relative_line_numbers: true` | ✅ |
| Tab size | `opt.tabstop = 2` | `tab_size: 2` | ✅ |
| Expand tabs | `opt.expandtab` | (автоматически) | ✅ |
| Auto indent | `opt.autoindent` | (автоматически) | ✅ |
| Cursor line | `opt.cursorline` | `current_line_highlight: "all"` | ✅ |
| System clipboard | `opt.clipboard` | `clipboard: "system"` | ✅ |
| Split right | `opt.splitright` | (автоматически) | ✅ |
| Split below | `opt.splitbelow` | (автоматически) | ✅ |
| Ignore case search | `opt.ignorecase` | `search.case_sensitive: "auto"` | ✅ |
| Wrap off | `opt.wrap = false` | `soft_wrap: "none"` | ✅ |
| Format on save | Neovim conform | `format_on_save: "on"` | ✅ |
| Inlay hints | LSP | `inlay_hints.enabled: true` | ✅ |
| Git gutter | Gitsigns | `git.git_gutter: "tracked_files"` | ✅ |
| Inline blame | Gitsigns | `git.inline_blame.enabled: true` | ✅ |

---

## 🔍 Дополнительные возможности Zed

В Zed есть несколько встроенных функций, которых нет в стандартной конфигурации nvim:

1. **Collaboration Panel** (`Ctrl+Shift+C`) - Совместная работа
2. **AI Assistant** (`Ctrl+Enter`) - Встроенный ИИ-помощник
3. **Quick Actions** (`Ctrl+Shift+A`) - Быстрые действия
4. **Command Palette** (`Ctrl+Shift+P`) - Палитра команд
5. **Project Panel** (`Ctrl+Shift+E`) - Панель проекта
6. **Symbol Search** (`Ctrl+Shift+O`) - Поиск символов
7. **Outline View** - Структура файла

---

## 💡 Полезные советы

### Навигация
- Используйте `Space Space` для быстрого поиска файлов (как `<Space><Space>` в nvim)
- `Space f g` для live grep (как `<leader>fg`)
- `Space l d` для go to definition (как `<leader>ld`)

### Git
- `Space g g` открывает LazyGit в плавающем окне kitty
- `Space g s` показывает git статус в project panel

### Окна
- `Ctrl+h/j/k/l` работает так же, как и в nvim
- `Space w e` выравнивает окна (как `<leader>we`)

### LSP
- Все LSP операции доступны через `Space l`
- Inlay hints включены по умолчанию
- Format on save включен

---

## 🆘 Отличия и ограничения

Некоторые функции nvim не имеют прямых аналогов в Zed:

1. **Undotree** - Используйте `Ctrl+Z` / `Ctrl+Shift+Z` для undo/redo
2. **Twilight** - Используйте Zen Mode (`Space u z`)
3. **Neotest** - Используйте встроенную панель тестов Zed
4. **Rails-specific** - Используйте LSP для навигации по Rails проектам
5. **Switch case plugin** - Используйте рефакторинг через LSP

---

## 📖 Дополнительные ресурсы

- [Zed Documentation](https://zed.dev/docs/)
- [Zed Keybindings](https://zed.dev/docs/key-bindings)
- [Zed Tasks](https://zed.dev/docs/tasks)
- [LazyVim Documentation](https://www.lazyvim.org/)

---

**Создано на основе конфигурации Neovim LazyVim от `/home/aboyarinov/.config/nvim`**
