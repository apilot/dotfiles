vim.cmd("let g:netrw_liststyle = 3")
if vim.g.neovide then
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_window_blurred = true
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
  vim.g.neovide_text_gamma = 0.0
  vim.g.ollama_split = "vsplit"
  vim.opt.linespace = 0
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0
  vim.g.neovide_text_contrast = 0.5
  vim.g.neovide_antialiasing = true
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
  vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode
end

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
local opt = vim.opt -- for conciseness
--
-- -- line numbers
-- opt.relativenumber = true -- show relative line numbers
-- opt.number = true -- shows absolute line number on cursor line (when relative number is on)
--
-- -- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one
opt.spelllang = "en_us,ru_yo,ru_ru"
opt.spell = true
--
-- -- line wrapping
-- opt.wrap = false -- disable line wrapping
--
-- -- search settings
-- opt.ignorecase = true -- ignore case when searching
-- opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive
--
-- -- cursor line
-- opt.cursorline = true -- highlight the current cursor line
--
-- -- appearance
--
-- -- turn on termguicolors for nightfly colorscheme to work
-- -- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
-- opt.signcolumn = "yes" -- show sign column so that text doesn't shift
--
-- -- backspace
-- opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position
--
-- -- clipboard
-- opt.clipboard:append("unnamedplus") -- use system clipboard as default register
--
-- -- split windows
-- opt.splitright = true -- split vertical window to the right
-- opt.splitbelow = true -- split horizontal window to the bottom
-- opt.syntax = "on"
--
-- -- turn off swapfile
-- opt.swapfile = false
opt.wrapmargin = 8 -- wrap lines when coming within n characters from side
opt.linebreak = true -- set soft wrapping
opt.showbreak = "↪ "
vim.g.lazyvim_prettier_needs_config = true
vim.g.lazyvim_ruby_lsp = "solargraph"
vim.g.lazyvim_ruby_formatter = "standardrb"
-- Hyprlang LSP
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.hl", "hypr*.conf" },
  callback = function(event)
    print(string.format("starting hyprls for %s", vim.inspect(event)))
    vim.lsp.start({
      name = "hyprlang",
      cmd = { "hyprls" },
      root_dir = vim.fn.getcwd(),
    })
  end,
})
