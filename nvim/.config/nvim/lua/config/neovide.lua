-- Neovide GUI specific settings
if vim.g.neovide then
  -- Visual effects
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_window_blurred = true
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
  vim.g.neovide_text_gamma = 0.0
  vim.g.neovide_text_contrast = 0.5
  vim.g.neovide_antialiasing = true

  -- Padding and spacing
  vim.opt.linespace = 0
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0

  -- macOS style keybindings
  vim.keymap.set("n", "<D-s>", ":w<CR>", { desc = "Save file" })
  vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to clipboard" })
  vim.keymap.set("n", "<D-v>", '"+P', { desc = "Paste normal mode" })
  vim.keymap.set("v", "<D-v>", '"+P', { desc = "Paste visual mode" })
  vim.keymap.set("c", "<D-v>", "<C-R>+", { desc = "Paste command mode" })
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli', { desc = "Paste insert mode" })
end

-- Global clipboard settings for all environments
vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

-- Font settings for GUI
vim.opt.guifont = { "MesloLGS Nerd Font:h10.:w-0.2:#h-slight" }
vim.opt.linespace = -1

-- Ollama integration settings
vim.g.ollama_split = "vsplit"