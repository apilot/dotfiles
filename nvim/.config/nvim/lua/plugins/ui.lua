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

  -- Word-under-cursor highlight (LSP + regex only; treesitter broken on Nvim 0.12)
  {
    "RRethy/vim-illuminate",
    opts = {
      providers = { "lsp", "regex" },
    },
  },

  -- Custom colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        leap = true,
        lazygit = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        fzf = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  },
}
