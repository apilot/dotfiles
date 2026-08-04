-- Development tools and utilities
return {
  -- Undo history visualization
  {
    "mbbill/undotree",
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" },
    },
  },

  -- Git diff viewer
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewRefresh" },
    keys = {
      { "<leader>gd", function() require("plugins.tools.utils").diff_open() end, desc = "Diff: MR-style (base...HEAD)" },
      { "<leader>gF", function() require("plugins.tools.utils").diff_open_full() end, desc = "Diff: full (base..HEAD)" },
      { "<leader>gD", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff: current file history" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diff: close" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_horizontal" },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = { flatten_dirs = true, folder_statuses = "only_folded" },
        win_config = { position = "left", width = 35 },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          vim.opt_local.wrap = false
          vim.opt_local.colorcolumn = {}
        end,
      },
    },
    config = function(_, opts)
      require("diffview").setup(opts)
    end,
  },
}
