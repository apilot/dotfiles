return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    -- opts = function(_, opts)
    --   local module = require("catppuccin.groups.integrations.bufferline")
    --   if module then
    --     module.get = module.get_theme
    --   end
    --   return opts
    -- end,
    priority = 1000,
    config = function()
      local colorscheme = "catppuccin"
      vim.g.catppuccin_flavour = "mocha"

      require("catppuccin").setup({
        -- configurations
        flavour = "mocha",
        dim_inactive = {
          enabled = true, -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.05, -- percentage of the shade to apply to the inactive window
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          fzf = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          markdown = true,
          mason = true,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          telescope = {
            enabled = true,
          },
          which_key = true,
        },
      })
    end,
  },
  -- {
  --   "akinsho/bufferline.nvim",
  --   optional = true,
  --   opts = function(_, opts)
  --     if (vim.g.colors_name or ""):find("catppuccin") then
  --       opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
  --     end
  --   end,
  -- },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        -- indent_blankline = { enabled = true },
        leap = true,
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
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      },
    },
  },
}
