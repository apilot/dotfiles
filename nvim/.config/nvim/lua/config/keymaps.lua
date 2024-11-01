-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap.set
keymap("n", "<leader>cz", "<cmd>ZenMode<cr>", { desc = "ZenMode toggle" }) -- split window vertically
keymap("n", "<leader>ct", "<cmd>Twilight<cr>", { desc = "Twilight toggle" }) -- split window vertically
keymap("n", "<leader>we", "<C-w>=", { desc = "Make windows equal size" }) -- make split windows equal width & height
keymap(
  "n",
  "<leader>c~",
  '<cmd>lua require("scripts.switch_case").switch_case()<CR>',
  { desc = "Switch to CamelCase/snake_case", noremap = true, silent = true }
) -- switch camel to snake case
