-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

keymap.set("n", "<leader>aa", "<cmd>AnyFoldActivate<CR>", { desc = "Auto folding all" }) -- split window vertically
-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set("n", "<leader>rr", "<cmd>Neotest run file<CR>", { desc = "Run Neotest test in file" })
keymap.set("n", "<leader>rl", "<cmd>Neotest run last<CR>", { desc = "Run Last test" })
keymap.set("n", "<leader>ra", "<cmd>Neotest attach<CR>", { desc = "Attach Neotest test" })
keymap.set("n", "<leader>ro", "<cmd>Neotest output<CR>", { desc = "Neotest output" })
keymap.set("n", "<leader>rs", "<cmd>Neotest summary<CR>", { desc = "Neotest summary" })
keymap.set("n", "<leader>rS", "<cmd>Neotest stop<CR>", { desc = "Neotest Stop" })
keymap.set("n", "<leader>rp", "<cmd>Neotest output-panel toggle<CR>", { desc = "Neotest panel toggle" })

keymap.set("n", "<leader>Fs", "<cmd>Telescope live_grep_args<CR>", { desc = "Global text search w args" })
keymap.set("n", "<leader>Ft", "<cmd>Telescope git_worktree git_worktrees<CR>", { desc = "List worktrees" })
keymap.set("n", "<leader>FT", "<cmd>Telescope git_worktree create_git_worktree<CR>", { desc = "Create worktree" })
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers list" })
keymap.set("n", "<leader>Fc", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Buffer text search" })
keymap.set("n", "<Tab><Tab>", "<cmd>fold-cycle-open<CR>", { desc = "Fold Cycle Open" })
keymap.set("n", "<S-Tab><S-Tab>", "<cmd>fold-cycle-close<CR>", { desc = "Fold Cycle Close" })
