# Zed Editor - Quick Cheatsheet

**Neovim LazyVim keybindings ported to Zed Editor**

---

## ❓ Which-Key (Нажми Space чтобы увидеть popup)

**Space** - покажет все доступные привязки (встроенная which-key)
**Space ?** - интерактивная справка (fzf)

---

## 🚀 Most Used

| Хоткей | Действие |
|--------|----------|
| `Space Space` | Найти файлы |
| `Space f g` | Поиск по содержимому (ripgrep) |
| `Space w` | Сохранить |
| `Space q` | Закрыть |
| `Space t t` | Терминал |
| `Space g g` | LazyGit |
| `Space e` | Файловый менеджер |

---

## 📁 Files (leader+f)

`Space ff` - Найти файлы
`Space fg` - Live grep
`Space fr` - Недавние файлы
`Space fb` - Буферы

---

## 🌿 Git (leader+g)

`Space gg` - LazyGit
`Space gs` - Git status
`Space gc` - Git commit
`Space gp` - Git push

---

## 💻 LSP (leader+l)

`Space lf` - Форматировать
`Space ld` - Go to definition
`Space li` - Go to implementation
`Space lr` - Find references
`Space ln` - Rename symbol
`Space la` - Code actions

---

## 🪟 Windows (leader+w)

`Space we` - Выровнять окна
`Space wv` - Split vertical
`Space wh` - Split horizontal
`Space wq` - Закрыть окно

**Навигация:**
`Ctrl+h/j/k/l` - Между окнами

---

## 🎨 UI (leader+u)

`Space uz` - Zen mode
`Space ul` - Toggle left dock
`Space ur` - Toggle right dock
`Space ub` - Toggle bottom dock

---

## ⚡ Quick Actions

`Space w` - Сохранить
`Space q` - Закрыть
`Space Q` - Выйти

---

## 🔧 Vim Mode

Все стандартные vim команды работают:
- `i` - insert mode
- `Esc` - normal mode
- `dd` - delete line
- `yy` - yank line
- `p` - paste
- `/` - search
- `n/N` - next/previous search result

---

**Полная документация:** `KEYMAP_REFERENCE.md`
