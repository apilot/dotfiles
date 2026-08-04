-- neogit: Magit-style Git TUI for Neovim.
-- Complements diffview (file-level diffs) with a full repository UI:
-- staging, commits, branching, log graph, push/pull — all keyboard-driven.
return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim", -- open diffs via diffview
    "folke/which-key.nvim",
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gn", "<cmd>Neogit kind=split<cr>", desc = "Neogit: open (Magit-style)" },
    { "<leader>gN", "<cmd>Neogit cwd=%:p:h kind=split<cr>", desc = "Neogit: open for current file's repo" },
    { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Neogit: commit log graph" },
  },
  opts = {
    -- Layout
    kind = "split", -- bottom split by default
    disable_signs = false,
    disable_context_highlighting = false,
    disable_commit_confirmation = true,

    -- Auto-refresh neogit buffer after git operations
    auto_refresh = true,

    -- Sort branches/tags by most recent commit
    sort_branches = "-committerdate",

    -- Commit message editor
    commit_editor = {
      kind = "split", -- open commit message in a split
      show_staged_diff = true,
    },

    -- Commit select view (for cherry-pick, revert, etc.)
    commit_select_view = {
      kind = "tab",
    },

    -- Log view config — graph similar to `git log --oneline --graph`
    log_view = {
      kind = "vsplit",
    },

    -- Integrations
    integrations = {
      diffview = true, -- `d` in neogit opens file in diffview
      telescope = nil, -- fzf-lua is used in this config, no telescope
    },

    -- Section styling
    sections = {
      sequencer = { folded = false, hidden = false },
      untracked = { folded = false, hidden = false },
      unstaged = { folded = false, hidden = false },
      staged = { folded = false, hidden = false },
      stashes = { folded = true, hidden = false },
      unpulled_upstream = { folded = true, hidden = false },
      unmerged_upstream = { folded = false, hidden = false },
      unpulled_pushremote = { folded = true, hidden = false },
      unmerged_pushremote = { folded = false, hidden = false },
      recent = { folded = true, hidden = false },
      rebase = { folded = true, hidden = false },
    },

    -- Highlight groups mapping (use editor theme)
    highlight = {
      italic = true,
      bold = true,
      underline = true,
    },

    -- File mapping overrides (none — use defaults)
    mappings = {
      -- Default neogit status buffer keys (kept for reference, all are defaults):
      --   Tab   toggle diff of item under cursor
      --   s     stage
      --   S     stage all unstaged
      --   u     unstage
      --   U     unstage all
      --   c     commit popup
      --   b     branch popup
      --   P     push popup
      --   p     pull popup
      --   l     log popup
      --   $     git command history
      status = {},
    },
  },
}
