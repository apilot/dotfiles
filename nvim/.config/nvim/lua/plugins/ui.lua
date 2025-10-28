-- UI and appearance plugins
return {
  -- Zen mode for distraction-free writing
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {},
  },

  -- Twilight for dimming inactive parts of code
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    opts = {},
  },

  -- Custom colorscheme (if exists)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = true,
        leap = true,
        lazygit = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = true,
        navic = true,
        neotree = true,
        neotest = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
        ufo = true,
      },
    },
  },
}
