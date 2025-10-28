-- LSP configurations have been moved to lua/plugins/lsp.lua
-- This file is kept for backward compatibility
print("Warning: LSP configuration moved to lua/plugins/lsp.lua")

-- LSP hotkeys are now managed in lua/config/keymaps.lua under <leader>l group
vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP Info" })
vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<cr>", { desc = "LSP Restart" })
