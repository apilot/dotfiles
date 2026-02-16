# Neovim LazyVim Code Standards

## Ruby on Rails Development

### LSP Configuration
- **Solargraph**: Ruby LSP (via rbenv)
  - Supports Ruby and ERB files
  - Provides completion, signatures, diagnostics
  - Uses rbenv for Ruby version management
  - Gem indexing is disabled for performance
  - Command: `rbenv exec solargraph stdio`
  - Hotkey: `<leader>lR` to restart Solargraph

### Formatting
- **StandardRB**: Auto-formatting on save
  - Supported filetypes:
    - `*.rb`, `*.rake`, `Gemfile`, `Rakefile`, `config.ru`
    - `*.erb` (Rails views) - uses htmlbeautifier + standardrb
    - `*.haml` (if used) - uses haml-lint
    - `*.slim` (if used) - uses slim-lint
  - Timeout: 10000ms (for large Rails files)
  - Auto-format on save: Enabled
  - Command: `rbenv exec standardrb --fix`

### Code Completion
- **nvim-cmp**: Primary completion engine (replaced blink.cmp)
  - Sources with priorities:
    - `cmp-nvim-lsp` (priority 1000) - Solargraph for Ruby
    - `cmp-tabnine` (priority 900) - AI completion, optimized for Ruby
    - `luasnip` (priority 800) - Snippets for Ruby
    - `cmp-path` (priority 500) - File paths in Rails projects
    - `cmp-buffer` (priority 250) - Local variables in Rails projects
  - TabNine AI completion: Version 4.321.0, installed and working

### Testing
- **RSpec via Neotest**: TDD support
  - Command: `bundle exec rspec`
  - Keymaps:
    - `<leader>tn` - Run nearest test
    - `<leader>tf` - Run test file
    - `<leader>ts` - Run test suite
    - `<leader>to` - Show test output

### Rails Navigation
- **vim-rails**: Fast navigation in Rails projects
  - Commands:
    - `:Econtroller` - Go to controller
    - `:Emodel` - Go to model
    - `:Eview` - Go to view
    - `:Helper` - Go to helper
    - `:Elocale` - Go to locale
    - `:Eserver` - Go to server
  - Keymaps:
    - `<leader>rc` - Goto controller
    - `<leader>rm` - Goto model
    - `<leader>rv` - Goto view
    - `<leader>rh` - Goto helper
    - `<leader>rl` - Goto locale
    - `<leader>rs` - Goto server

### Ruby Refactoring
- **Multicursor**: Multi-cursor editing for efficient refactoring
  - Keymaps: `<A-j>` (add cursor below), `<A-k>` (add cursor above)
  - Supports RSpec testing integration

### Keymaps Summary

#### Git Operations (`<leader>g`)
- `<leader>gg` - LazyGit (LazyVim default)
- `<leader>gs` - Git status
- `<leader>gc` - Git commit
- `<leader>gp` - Git push

#### Rails Operations (`<leader>r`)
- `<leader>rc` - Goto controller
- `<leader>rm` - Goto model
- `<leader>rv` - Goto view
- `<leader>rh` - Goto helper
- `<leader>rl` - Goto locale
- `<leader>rs` - Goto server

#### Testing Operations (`<leader>t`)
- `<leader>tn` - Run nearest test
- `<leader>tf` - Run test file
- `<leader>ts` - Run test suite
- `<leader>to` - Show test output

#### LSP Operations (`<leader>l`)
- `<leader>lf` - Format with Standard
- `<leader>li` - LSP Implementations
- `<leader>la` - LSP Code Actions
- `<leader>ld` - LSP Definitions
- `<leader>ln` - Rename symbol
- `<leader>lI` - LSP Info
- `<leader>lR` - LSP Restart (Solargraph)

#### Multicursor (Alt + j/k)
- `<A-j>` - Add cursor below
- `<A-k>` - Add cursor above
- `<leader>j` - Skip cursor below
- `<leader>k` - Skip cursor above
- `<A-n>` - Add cursor by matching word
- `<A-s>` - Skip cursor by matching word
- `<C-q>` - Toggle cursor

## General Editor Settings

### Ruby-specific
- Tab size: 2 spaces
- Indent size: 2 spaces
- Expand tabs to spaces: enabled
- Spell checking: English + Russian
- Line wrapping: disabled
- Relative line numbers: enabled

### File Explorer
- **Snacks.explorer**: Primary file manager
- Replaces netrwPlugin (disabled for performance)

### UI Plugins
- **Noice.nvim**: Messages, cmdline, popupmenu
- **Snacks.nvim**: Explorer, picker, dashboard, indent, statuscolumn
- Overlapping modules in Snacks are disabled (notifier, input, win)

## Plugin Architecture

### Core Plugins
- LazyVim (framework)
- nvim-cmp (completion)
- Noice.nvim (UI)
- Snacks.nvim (explorer, dashboard, etc.)

### Ruby-specific Plugins
- nvim-lspconfig (Solargraph, RuboCop)
- conform.nvim (StandardRB formatting)
- neotest (RSpec testing)
- vim-rails (navigation)
- multicursor.nvim (multi-cursor refactoring)
- vim-ruby (syntax highlighting)

### Development Tools
- fzf-lua (fuzzy finding)
- todo-comments.nvim (TODO/FIXME)
- git-worktree.nvim (branch management)
- multicursor.nvim (multi-cursor editing)
- csvview.nvim (CSV data viewing)

## Performance Optimizations

### For Large Rails Projects
- `reset_packpath = true` in lazy.lua
- Timeout for StandardRB: 10000ms
- Disabled netrwPlugin (using Snacks.explorer)
- Disabled unused plugins:
  - equalsraf/neovim-gui-shim
  - jpmcb/nvim-llama
  - nvim-mini/mini.nvim (LazyVim includes mini.ai, mini.surround)

### Disabled Autocmds
- Removed force completion on InsertEnter
- Removed trigger completion on TextChangedI
- Completion now works naturally through LSP and nvim-cmp

## File Structure

### Configuration Files
- `lua/config/lazy.lua` - Plugin manager setup
- `lua/config/editor.lua` - Basic editor settings
- `lua/config/keymaps.lua` - Keybindings
- `lua/config/autocmds.lua` - Autocommands
- `lua/config/languages.lua` - Language-specific configurations

### Plugin Files
- `lua/plugins/lsp.lua` - LSP configuration (Solargraph, RuboCop)
- `lua/plugins/cmp.lua` - nvim-cmp setup
- `lua/plugins/conform.lua` - Formatter configuration
- `lua/plugins/ruby.lua` - Ruby-specific plugins
- `lua/plugins/neotests.lua` - Testing configuration
- `lua/plugins/noice.lua` - UI configuration
- `lua/plugins/snacks.lua` - Snacks configuration
- `lua/plugins/tools.lua` - Development tools
- `lua/plugins/plugins.lua` - Additional plugins

## Notes

### Solargraph Setup
- Solargraph must be installed via rbenv or gem
- Command: `gem install solargraph`
- LSP uses: `rbenv exec solargraph stdio`
- Formatting is disabled (using StandardRB instead)

### StandardRB Setup
- StandardRB must be installed via rbenv or gem
- Command: `gem install standardrb`
- Formatter uses: `rbenv exec standardrb --fix`
- Auto-formats on save for all Ruby files

### RuboCop Setup
- RuboCop must be installed via rbenv or gem
- Command: `gem install rubocop`
- LSP uses: `rbenv exec rubocop --lsp`
- Provides real-time diagnostics
- Rails-specific rules enabled

### TabNine Setup
- TabNine binary is auto-installed
- AI completion optimized for Ruby
- Works with Solargraph LSP
- Priority: 900 (below LSP, above snippets)

### RSpec Testing
- Neotest requires RSpec gem
- Command: `bundle exec rspec`
- Uses bundle to run tests in Rails projects
- Supports nearest, file, and suite test runs

### Rails Navigation
- vim-rails requires Rails project structure
- Recognizes standard Rails directories
- Fast switching between controllers, models, views
- Works with any Rails version
