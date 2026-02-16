# 💤 Neovim Configuration

Мощная конфигурация Neovim на основе [LazyVim](https://github.com/LazyVim/LazyVim), оптимизированная для **Ruby on Rails** разработки с улучшенными функциями продуктивности и поддержкой разработки.

## ✨ Особенности

- 🚀 **Быстрый старт** - автоматическая установка плагинов при первом запуске
- 🎨 **Современный интерфейс** - тема Catppuccin с режимами Zen и Twilight
- 🔍 **Умный поиск** - FZF-lua для быстрого поиска файлов и содержимого
- 📁 **Управление файлами** - Snacks.explorer с полной интеграцией
- 🔧 **Ruby on Rails разработка** - полная поддержка с LSP, автоформатированием и тестированием
- 🤖 **AI ассистенты** - интеграция с Aider (Qwen) и Ollama
- ⚡ **Git интеграция** - LazyGit с полной интеграцией с Neovim
- 💾 **Управление сессиями** - автоматическое сохранение и восстановление
- 🌊 **Плавная прокрутка** - комфортная навигация
- 🧪 **Тестирование** - RSpec интеграция через Neotest

## 📁 Структура

```
lua/
├── config/          # Основная конфигурация
│   ├── editor.lua   # Настройки редактора
│   ├── keymaps.lua  # Горячие клавиши
│   ├── languages.lua # Языковые настройки
│   ├── autocmds.lua # Автокоманды
│   ├── lazy.lua     # Lazy.nvim конфигурация
│   ├── neovide.lua  # Настройки GUI
└── plugins/         # Плагины
    ├── ui.lua       # Интерфейс (темы, zen-mode)
    ├── lsp.lua      # LSP и автодополнение
    ├── tools.lua    # Инструменты (lazygit, neo-tree)
    ├── editing.lua  # Улучшения редактирования
    ├── fzf.lua      # FZF поиск
    ├── ai.lua       # AI ассистенты
    ├── colorsheme.lua # Цветовые схемы
    ├── conform.lua  # Форматирование кода
    ├── which-key.lua # Помощник по горячим клавишам
    ├── snacks.lua   # Индикатор прогресса
    └── ...         # Специализированные плагины
```

## 🎨 Интерфейс

### Темы и оформление

- **Catppuccin** - современная цветовая схема с акцентами
- **Zen Mode** - фокусированный режим без отвлекающих элементов
- **Twilight** - затемнение неактивного кода
- **Dim** - автоматическое затемнение неактивных окон
- **Indent-blankline** - визуальные отступы

### Улучшения интерфейса

- **Smooth scrolling** - плавная прокрутка
- **Better escape** - улучшенный выход из режимов
- **Illuminate** - подсветка текущего слова
- **Navic** - навигационная строка
- **Lualine** - информационная строка состояния

## ⌨️ Горячие клавиши

### 📂 Работа с файлами (`<leader>f`)

- `<leader>ff` - Найти файлы (fzf-lua)
- `<leader>fg` - Поиск по содержимому (fzf-lua)
- `<leader>fb` - Найти буферы (fzf-lua)
- `<leader>fh` - История файлов (fzf-lua)
- `<leader>fc` - Команды (fzf-lua)
- `<leader>fl` - Найденные слова (fzf-lua)
- `<leader>fe` - Файловый менеджер (Neo-tree)

### 🔧 Работа с кодом (`<leader>c`)

- `<leader>cc` - Переключить CamelCase ↔ snake_case
- `<leader>cf` - Форматировать буфер
- `<leader>ca` - Действия с кодом (code actions)
- `<leader>cd` - Перейти к определению
- `<leader>cr` - Переименовать символ

### 🌿 Git операции (`<leader>g`)

- `<leader>gg` - **LazyGit** (LazyVim default, автоматически)
- `<leader>gs` - Git status
- `<leader>gc` - Git commit
- `<leader>gp` - Git push
- `<leader>gb` - Git blame
- `<leader>gd` - Git diff

### 🚂 Ruby on Rails (`<leader>r`)

- `<leader>rc` - Перейти к контроллеру (`:Econtroller`)
- `<leader>rm` - Перейти к модели (`:Emodel`)
- `<leader>rv` - Перейти к вью (`:Eview`)
- `<leader>rh` - Перейти к хелперу (`:Helper`)
- `<leader>rl` - Перейти к локализации (`:Elocale`)
- `<leader>rs` - Перейти к серверу (`:Eserver`)

### 🧪 Тестирование RSpec (`<leader>t`)

- `<leader>tn` - Запустить ближайший тест
- `<leader>tf` - Запустить тестовый файл
- `<leader>ts` - Запустить весь тестовый набор
- `<leader>to` - Показать вывод тестов

### 💬 LSP операции (`<leader>l`)

- `<leader>li` - LSP информация
- `<leader>lr` - Перезапустить LSP
- `<leader>lf` - Форматировать через LSP
- `<leader>la` - Действия с кодом LSP
- `<leader>ld` - Перейти к определению
- `<leader>lrn` - Переименовать через LSP
- `<leader>lR` - Перезапустить LSP
- `<leader>lI` - Информация о LSP
- `<leader>lD` - Показать определение в float
- `<leader>lt` - Показать тип
- `<leader>ls` - Показать символы

### 🪟 Управление окнами (`<leader>w`)

- `<leader>we` - Сделать окна равного размера
- `<leader>wv` - Разделить вертикально
- `<leader>wh` - Разделить горизонтально
- `<leader>wq` - Закрыть окно
- `<leader>ws` - Разделить окно
- `<leader>w-` - Уменьшить высоту
- `<leader>w+` - Увеличить высоту
- `<leader>w<` - Уменьшить ширину
- `<leader>w>` - Увеличить ширину
- `<leader>wo` - Закрыть другие окна

### 🧠 AI ассистенты (`<leader>a`)

- `<leader>ag` - Сгенерировать с AI
- `<leader>ac` - Чат с AI
- `<leader>al` - Переключить сессию LLM
- `<leader>aa` - Спросить Avante
- `<leader>ae` - Редактировать с Avante
- `<leader>ar` - Объяснить код
- `<leader>af` - Исправить код

### 🎨 Интерфейс (`<leader>u`)

- `<leader>uz` - Переключить Zen Mode
- `<leader>ut` - Переключить Twilight
- `<leader>ud` - Отладочный режим
- `<leader>ui` - Информация о компонентах UI
- `<leader>us` - Переключить боковую панель

### 🌐 Навигация

- `<C-h>` - Перейти в левое окно
- `<C-j>` - Перейти в нижнее окно
- `<C-k>` - Перейти в верхнее окно
- `<C-l>` - Перейти в правое окно
- `<leader>w` - Сохранить файл
- `<leader>q` - Выйти
- `<leader>Q` - Выйти из всех

### 💾 Терминал (`<leader>t`)

- `<leader>tt` - Открыть терминал
- `<leader>tg` - Создать временный git репозиторий
- `<leader>td` - Запустить docker контейнер
- `<leader>th` - История команд
- `<leader>tj` - Форматировать JSON
- `<leader>tc` - Удалить историю терминала
- `<leader>tL` - Удалить всю историю терминала

### 🔤 Текстовые операции

- `<leader>u` - Отменить (Undo Tree)
- `<leader>x` - Закрыть буфер
- `<leader>X` - Принудительно закрыть буфер
- `<leader>b` - Удалить буфер
- `<leader>B` - Принудительно удалить буфер

### 📄 Кодировки (`<leader>E`)

- `<leader>Ew` - Windows CP1251
- `<leader>Eu` - UTF-8
- `<leader>Ej` - Форматировать JSON с jq

### 📊 CSV (`<leader>C`)

- `<leader>Cc` - CSV с запятой
- `<leader>Cs` - CSV с точкой с запятой

## 🚀 Установка

1. **Сделайте бэкап существующей конфигурации:**

   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   mv ~/.local/share/nvim ~/.local/share/nvim.backup
   ```

2. **Клонируйте репозиторий:**

   ```bash
   git clone https://github.com/yourusername/nvim-config.git ~/.config/nvim
   ```

3. **Запустите Neovim:**
   ```bash
   nvim
   ```
   Плагины установятся автоматически при первом запуске.

## 📋 Зависимости

### Обязательные

- **Neovim 0.8+**
- **Git**
- **Ripgrep** (для поиска fzf-lua)
- **Node.js** (для некоторых LSP серверов)
- **Python 3** (для некоторых LSP серверов)

### Для Ruby on Rails разработки

- **rbenv**: управление версиями Ruby (требуется для Solargraph, StandardRB, RuboCop)
- **Solargraph**: `gem install solargraph` - Ruby LSP
- **StandardRB**: `gem install standardrb` - Ruby formatter
- **RuboCop**: `gem install rubocop rubocop-rails rubocop-rspec` - Ruby linter
- **RSpec**: добавляется в Gemfile Rails проекта - тестирование
- **Node.js**: (опционально) для некоторых инструментов Rails
- **bundler**: `gem install bundler` - управление гемами

**Примечание:** Все Ruby инструменты (Solargraph, StandardRB, RuboCop) используют `rbenv` для выполнения.

### Для других языков

- **Lua**: `stylua` (форматирование)
- **Shell**: `shfmt` (форматирование)
- **Hyprland**: `hyprls` (LSP, опционально)

### AI инструменты (опционально)

- **Ollama**: для локальных моделей
- **Claude API ключ**: для интеграции с Claude

## 🎯 Основные возможности

### 💻 Разработка

#### Ruby on Rails

- **Solargraph LSP** - полный Language Server Protocol для Ruby и ERB
  - Автодополнение Rails методов (belongs_to, has_many, validates)
  - Перейти к определению в контроллерах, моделях, хелперах
  - Hover документация для Rails API
  - Подписи методов (signature help)

- **RuboCop LSP** - статический анализ и style checking
  - Real-time diagnostics в редакторе
  - Rails-specific правила
  - Легко настраивается через `.rubocop.yml`

- **StandardRB** - автоформатирование при сохранении
  - Поддерживает: `*.rb`, `*.rake`, `Gemfile`, `Rakefile`, `config.ru`
  - ERB файлы: использует htmlbeautifier + standardrb
  - HAML файлы: haml-lint (если используется)
  - SLIM файлы: slim-lint (если используется)

- **RSpec тестирование** - через Neotest
  - Запуск тестов: nearest, file, suite
  - Просмотр результатов тестов
  - Интеграция с bundle exec rspec

- **Rails навигация** - через vim-rails
  - Быстрое переключение между контроллерами, моделями, вью
  - Поддержка стандартной структуры Rails проекта
  - Команды: `:Econtroller`, `:Emodel`, `:Eview`, `:Helper`, `:Elocale`, `:Eserver`

- **Мультикурсор** - для рефакторинга
  - Alt + j/k - добавить курсор ниже/выше
  - Быстрое редактирование в нескольких местах

- **Автодополнение** - TabNine AI + LSP
  - cmp-tabnine (AI, оптимизирован для Ruby, priority 900)
  - cmp-nvim-lsp (Solargraph, priority 1000)
  - cmp-buffer (локальные переменные, priority 250)
  - cmp-path (пути в Rails проектах, priority 500)
  - Luasnip (snippets, priority 800)

- **Подсветка синтаксиса** - vim-ruby
  - Enhanced подсветка Ruby кода
  - Поддержка всех версий Ruby

- **Slim шаблоны** - полная поддержка (через vim-slim.lua)

#### Другие языки

- **Lua** - встроенный LSP
- **Hyprland** - подсветка конфигурационных файлов
- **Markdown** - улучшенная поддержка с предпросмотром
- **JSON/YAML** - подсветка и валидация

### 🔍 Поиск и навигация

- **FZF-lua** - сверхбыстрый поиск файлов и содержимого
- **Neo-tree** - мощный файловый менеджер
- **Telescope** - дополнительный поиск
- **Smooth scrolling** - комфортная прокрутка

### 🤖 AI интеграция

- **Множественные провайдеры**: Claude, Ollama, локальные модели
- **Генерация кода**: в редакторе и через чат
- **Контекстная помощь**: с учетом текущих файлов

### 🔧 Git

- **LazyGit** в модальном окне (90% экрана)
- **Прямая интеграция** с текущим Neovim
- **Файлы открываются** в том же окне при `o`
- **Без врапперов** и прослоек
- **Git signs** - визуальные индикаторы изменений

### 🎨 UI/UX

- **Catppuccin тема** с множеством акцентов
- **Zen Mode** для концентрации
- **Twilight** для фокусировки
- **Автоматическое затемнение** неактивных окон
- **Better escape** для улучшенного управления режимами

## 💾 Сессии и workspace

### Auto-session

- **Автосохранение** при выходе
- **Автовосстановление** при входе
- **Работа с ветками** - сессии по веткам Git
- **Управление** через `:SessionRestore`, `:SessionSave`

### Управление буферами

- **Smart tab** - улучшенные табы
- **Better buffer** - удаление буферов без закрытия окон
- **Autopairs** - автоматические пары скобок и кавычек
- **Surround** - удобное управление окружающими символами

## 🔧 Конфигурация

### Кастомизация плагинов

Все плагины легко настраиваются через соответствующие файлы в `lua/plugins/`:

```lua
-- Пример настройки темы в lua/plugins/colorsheme.lua
{
  "catppuccin/nvim",
  name = "catppuccin",
  opts = {
    flavour = "mocha",
    background = { dark = "mocha" },
    integrations = { ... }
  }
}
```

### Добавление новых горячих клавиш

```lua
-- В lua/config/keymaps.lua
keymap("n", "<leader>yourkey", "<cmd>YourCommand<cr>", { desc = "Ваше описание" })
```

### Настройка языков

```lua
-- В lua/config/languages.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yourfiletype",
  callback = function()
    -- Ваша настройка
  end
})
```

## 🎯 Особенности

### LazyGit интеграция

- **Модальное окно** - 90% экрана по центру
- **Никаких врапперов** - прямой запуск lazygit
- **Полная интеграция** - файлы открываются в текущем Neovim
- **Умное окружение** - автоматическая настройка переменных

### Ruby on Rails разработка

- **Полный LSP** - Solargraph (Ruby, ERB) + RuboCop (style checking)
- **Автоформатирование** - StandardRB при сохранении всех Ruby файлов
- **Rails навигация** - быстрые переходы между контроллерами, моделями, вью
- **RSpec тестирование** - Neotest интеграция с keymaps
- **AI автодополнение** - TabNine (оптимизирован для Ruby)
- **Rails методы** - автодополнение belongs_to, has_many, validates, render, redirect_to
- **Поддержка шаблонов** - ERB, HAML, SLIM с форматированием
- **Gemfile** автодополнение - всех Ruby dependencies
- **Rake tasks** автодополнение - для Rails задач

### AI инструменты

- **Claude API** для облачных моделей
- **Ollama** для локальных моделей
- **Gen** для быстрой генерации
- **Avante** для контекстной помощи

## 📚 Дополнительная документация

- [**Полное описание на русском**](README_RU.md) - подробная русская документация
- [**Обзор проекта**](PROJECT_OVERVIEW.md) - архитектура и технические детали
- [**Ruby on Rails Setup Guide**](RUBY_SETUP.md) - полное руководство по настройке Ruby инструментов
- [**Code Standards**](.opencode/context/core/standards/code.md) - стандарты кодирования и конфигурация

## 🤝 Вклад

Не стесняйтесь отправлять:

- **Issue** - баги и предложения
- **Pull requests** - улучшения и новые функции
- **Документацию** - исправления и дополнения

## 📄 Лицензия

MIT License - свободное использование и распространение

---

**Наслаждайтесь продуктивной разработкой!** 🚀
