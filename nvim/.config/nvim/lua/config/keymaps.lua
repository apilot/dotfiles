-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap.set
keymap("n", "<leader>cz", "<cmd>ZenMode<cr>", { desc = "ZenMode toggle" })
keymap("n", "<leader>ct", "<cmd>Twilight<cr>", { desc = "Twiligt toggle" })
keymap("n", "<leader>ce", "<c-e>", { desc = "Special edit opts", remap = true })
keymap("n", "<leader>ceW", "<cmd>:e ++enc=cp1251<cr>", { desc = "CP1251 codepage" }) -- switc to cp1251 codepage
keymap("n", "<leader>ceU", "<cmd>:e ++enc=utf-8<cr>", { desc = "UTF8 codepage" }) -- switch to cp1251 codepage
keymap("n", "<leader>cec", "<cmd>:CsvViewToggle delimiter=, comment=#<cr>", { desc = "Edit CSV with , delimiter" }) -- switch CSV view with comma delimiter
keymap("n", "<leader>ceC", "<cmd>:CsvViewToggle delimiter=; comment=#<cr>", { desc = "Edit CSV with ; delimiter" }) -- switch CSV view with ; delimiter
keymap("n", "<leader>ceJ", "<cmd>:%!jq<cr>", { desc = "JSON ident" }) -- switch to cp1251 codepage
keymap("n", "<leader>we", "<C-w>=", { desc = "Make windows equal size" }) -- make split windows equal width & height
keymap(
  "n",
  "<leader>c~",
  '<cmd>lua require("scripts.switch_case").switch_case()<CR>',
  { desc = "Switch to CamelCase/snake_case", noremap = true, silent = true }
) -- switch camel to snake case
