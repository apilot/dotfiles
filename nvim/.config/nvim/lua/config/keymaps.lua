-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap.set

-- UI & Appearance (<leader>u)
keymap("n", "<leader>uz", "<cmd>ZenMode<cr>", { desc = "Zen Mode toggle" })
keymap("n", "<leader>ut", "<cmd>Twilight<cr>", { desc = "Twilight toggle" })

-- Code editing (<leader>c)
keymap("n", "<leader>ce", "<c-e>", { desc = "Special edit opts", remap = true })
keymap(
  "n",
  "<leader>cc",
  '<cmd>lua require("scripts.switch_case").switch_case()<CR>',
  { desc = "Switch CamelCase/snake_case", noremap = true, silent = true }
)
keymap("n", "<leader>cf", "<cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format current buffer" })

keymap("n", "<leader>e", "<cmd>lua Snacks.explorer()<cr>", { desc = "File Explorer" })
-- File operations (<leader>f)
keymap("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
keymap("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
keymap("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Find buffers" })
keymap("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", { desc = "Help tags" })
keymap("n", "<leader>fc", "<cmd>FzfLua commands<cr>", { desc = "Commands" })
keymap("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent files" })
keymap("n", "<leader>fk", "<cmd>FzfLua keymaps<cr>", { desc = "Keymaps" })

-- Git operations (<leader>g)
keymap("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })
keymap("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
keymap("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" })

-- Rails operations (<leader>r)
keymap("n", "<leader>rc", "<cmd>Econtroller<cr>", { desc = "Rails: Goto controller" })
keymap("n", "<leader>rm", "<cmd>Emodel<cr>", { desc = "Rails: Goto model" })
keymap("n", "<leader>rv", "<cmd>Eview<cr>", { desc = "Rails: Goto view" })
keymap("n", "<leader>rh", "<cmd>Helper<cr>", { desc = "Rails: Goto helper" })
keymap("n", "<leader>rl", "<cmd>Elocale<cr>", { desc = "Rails: Goto locale" })
keymap("n", "<leader>rs", "<cmd>Eserver<cr>", { desc = "Rails: Goto server" })

-- RSpec/Testing operations (<leader>t)
keymap("n", "<leader>tn", function() require("neotest").run.run() end, { desc = "Run nearest test" })
keymap("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run test file" })
keymap("n", "<leader>ts", function() require("neotest").run.run({ suite = true }) end, { desc = "Run test suite" })
keymap("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end, { desc = "Show test output" })

-- Encoding & File format (<leader>E)
keymap("n", "<leader>Ew", "<cmd>:e ++enc=cp1251<cr>", { desc = "Windows CP1251" })
keymap("n", "<leader>Eu", "<cmd>:e ++enc=utf-8<cr>", { desc = "UTF-8" })
keymap("n", "<leader>Ej", "<cmd>:%!jq<cr>", { desc = "JSON format with jq" })

-- CSV operations (<leader>C)
keymap("n", "<leader>Cc", "<cmd>:CsvViewToggle delimiter=, comment=#<cr>", { desc = "CSV with comma" })
keymap("n", "<leader>Cs", "<cmd>:CsvViewToggle delimiter=; comment=#<cr>", { desc = "CSV with semicolon" })

-- Window management (<leader>w)
keymap("n", "<leader>we", "<C-w>=", { desc = "Make windows equal size" })
keymap("n", "<leader>wv", "<C-w>v", { desc = "Split vertical" })
keymap("n", "<leader>wh", "<C-w>s", { desc = "Split horizontal" })
keymap("n", "<leader>wq", "<C-w>q", { desc = "Close window" })

-- Session management (<leader>S)
keymap("n", "<leader>Ss", "<cmd>SessionSave<cr>", { desc = "Save session" })
keymap("n", "<leader>Sl", "<cmd>SessionLoad<cr>", { desc = "Load session" })

-- Quick navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Quick save/quit
keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
keymap("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })


-- LSP operations (<leader>l) - using fzf-lua where possible
keymap("n", "<leader>li", "<cmd>FzfLua lsp_implementations<cr>", { desc = "LSP Implementations" })
keymap("n", "<leader>lr", "<cmd>FzfLua lsp_references<cr>", { desc = "LSP References" })
keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format buffer" })
keymap("n", "<leader>la", "<cmd>FzfLua lsp_code_actions<cr>", { desc = "LSP Code Actions" })
keymap("n", "<leader>ld", "<cmd>FzfLua lsp_definitions<cr>", { desc = "LSP Definitions" })
keymap("n", "<leader>ln", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename symbol" })
-- LSP utility commands (moved to avoid conflicts)
keymap("n", "<leader>lI", "<cmd>LspInfo<cr>", { desc = "LSP Info" })
keymap("n", "<leader>lR", "<cmd>LspRestart<cr>", { desc = "LSP Restart" })

-- Terminal
keymap("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Open terminal" })

-- AI Assistant operations (<leader>a)
keymap("n", "<leader>aa", "<cmd>AiderOpen<cr>", { desc = "Open Aider" })
keymap("v", "<leader>aa", "<cmd>AiderOpen<cr>", { desc = "Open Aider" })
keymap("n", "<leader>am", "<cmd>AiderAddModifiedFiles<cr>", { desc = "Add modified files" })

-- Terminal key mappings
vim.cmd([[
  " ESC mapping for normal terminals (but exclude lazygit)
  autocmd TermOpen * if &filetype != 'lazygit' | tnoremap <buffer> <Esc> <C-\><C-n> | endif
]])
