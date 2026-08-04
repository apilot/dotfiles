-- Git inline annotations (gitsigns.nvim).
-- LazyVim already provides default keymaps (<leader>gh* group);
-- this spec extends opts without overriding the LazyVim spec.
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    -- Inline +/- highlight inside modified lines (word-level diff)
    word_diff = true,

    -- Show author of the current line as virtual text (GitLab "blame" style)
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- display at the end of line
      delay = 300,
      ignore_whitespace = false,
      virt_text_priority = 100,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",

    -- Signs customization (kept close to defaults, slightly bolder)
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },

    -- Highlight only the changed characters, not the full line
    signcolumn = true,
    numhl = false,
    linehl = false,

    -- Preview window styling
    preview_config = {
      border = "rounded",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },

    -- Automatically attach to git-tracked buffers
    auto_attach = true,
    attach_to_untracked = true,

    -- Update signs on cursor move / text change
    watch_gitdir = { follow_files = true },
    update_debounce = 100,
  },
}
