# 💤 LazyVim Configuration

Custom Neovim configuration based on [LazyVim](https://github.com/LazyVim/LazyVim) with enhanced productivity features and Ruby development support.

## 📁 Structure

### Configuration Files (`lua/config/`)

- **`editor.lua`** - Basic editor settings (numbers, indentation, search)
- **`neovide.lua`** - GUI-specific settings and macOS keybindings
- **`languages.lua`** - Language-specific configurations (Ruby, Hyprland)
- **`keymaps.lua`** - Custom hotkeys organized by functionality
- **`autocmds.lua`** - Custom automatic commands
- **`lazy.lua`** - Lazy.nvim configuration and plugin management

### Plugin Categories (`lua/plugins/`)

- **`ui.lua`** - UI plugins (zen-mode, twilight, colorscheme)
- **`editing.lua`** - Editing enhancements (formatting, autopairs, surround)
- **`tools.lua`** - Development tools (file explorer, git, sessions)
- **`lsp.lua`** - Language Server Protocol and completion
- **`ai.lua`** - AI assistants (gen, llm, avante)
- **Individual plugins** - Specialized configurations (treesitter, obsidian, etc.)

## ⌨️ Key Mappings

### Code Operations (`<leader>c`)
- `<leader>cc` - Switch CamelCase/snake_case
- `<leader>cf` - Format current buffer
- `<leader>ce` - Special edit options

### File Operations (`<leader>f`)
- `<leader>fe` - File explorer (Neo-tree)
- `<leader>ff` - Find files (Telescope)
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers

### Git Operations (`<leader>g`)
- `<leader>gg` - LazyGit
- `<leader>gs` - Git status
- `<leader>gc` - Git commit
- `<leader>gp` - Git push

### LSP Operations (`<leader>l`)
- `<leader>li` - LSP Info
- `<leader>lr` - LSP Restart
- `<leader>lf` - Format buffer
- `<leader>la` - Code actions
- `<leader>ld` - Go to definition
- `<leader>lrn` - Rename symbol

### Window Management (`<leader>w`)
- `<leader>we` - Make windows equal size
- `<leader>wv` - Split vertical
- `<leader>wh` - Split horizontal
- `<leader>wq` - Close window

### Encoding & File Format (`<leader>E`)
- `<leader>Ew` - Windows CP1251 encoding
- `<leader>Eu` - UTF-8 encoding
- `<leader>Ej` - Format JSON with jq

### CSV Operations (`<leader>C`)
- `<leader>Cc` - CSV with comma delimiter
- `<leader>Cs` - CSV with semicolon delimiter

### UI & Appearance (`<leader>u`)
- `<leader>uz` - Toggle Zen Mode
- `<leader>ut` - Toggle Twilight

### AI Assistants (`<leader>a`)
- `<leader>ag` - Generate with AI
- `<leader>ac` - AI Chat
- `<leader>al` - Toggle LLM Session
- `<leader>aa` - Ask Avante
- `<leader>ae` - Edit with Avante

### Quick Navigation
- `<C-h/j/k/l>` - Navigate between windows
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>Q` - Quit all
- `<leader>tt` - Open terminal

## 🚀 Features

### Development Environment
- **Ruby Development**: Solargraph LSP, StandardRB formatting
- **Hyprland Support**: LSP for Hyprland configuration files
- **Git Integration**: LazyGit, fugitive, git signs
- **File Management**: Neo-tree explorer, Telescope search
- **Session Management**: Auto-save/restore sessions

### AI Integration
- **Multiple AI providers**: Claude, local models via Ollama
- **Code generation**: In-line generation and chat interfaces
- **Contextual assistance**: File-aware AI interactions

### UI Enhancements
- **Zen Mode**: Distraction-free writing
- **Twilight**: Dim inactive code sections
- **Catppuccin theme**: Modern color scheme
- **Better navigation**: Smooth scrolling, window management

### Productivity Tools
- **Auto-formatting**: On-save formatting for multiple languages
- **Case switching**: CamelCase ↔ snake_case conversion
- **CSV editing**: Toggle table view for CSV files
- **Encoding support**: Quick switching between text encodings

## 🔧 Installation

1. Backup your existing Neovim configuration
2. Clone this repository to `~/.config/nvim`
3. Run Neovim - plugins will be automatically installed
4. Ensure required tools are installed:
   - `solargraph` (Ruby LSP)
   - `standardrb` (Ruby formatter)
   - `hyprls` (Hyprland LSP, optional)

## 📚 Dependencies

### Required
- Neovim 0.8+
- Git
- `ripgrep` (for Telescope search)

### Language Specific
- Ruby: `solargraph`, `standardrb`
- Lua: `stylua`
- Shell: `shfmt`
- Hyprland: `hyprls` (optional)

### AI Tools (optional)
- `ollama` (for local models)
- `claude` API key (for Claude integration)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!
test change
