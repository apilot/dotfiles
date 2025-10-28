-- Basic editor settings
local opt = vim.opt

-- Line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line

-- Tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- Line wrapping
opt.wrap = false -- disable line wrapping
opt.wrapmargin = 8 -- wrap lines when coming within n characters from side
opt.linebreak = true -- set soft wrapping
opt.showbreak = "↪ "

-- Search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- Cursor line
opt.cursorline = true -- highlight the current cursor line

-- Appearance
opt.termguicolors = true -- turn on termguicolors for colorschemes to work
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- Backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- Clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- Split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- Other settings
opt.syntax = "on"
opt.swapfile = false -- turn off swapfile

-- Spell checking
opt.spelllang = "en_us,ru_yo,ru_ru"
opt.spell = true

-- Netrw settings
vim.cmd("let g:netrw_liststyle = 3")

-- LazyVim specific settings
vim.g.lazyvim_prettier_needs_config = true
vim.g.lazyvim_ruby_lsp = "solargraph"
vim.g.lazyvim_ruby_formatter = "standardrb"