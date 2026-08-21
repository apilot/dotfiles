return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    explorer = { enabled = true },
    lazygit = {
      configure = true,
      win = {
        style = "lazygit",
      },
      config = {
        os = {
          edit = "lg-edit {{filename}}",
        },
      },
    },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["?"] = function(win)
                  win:toggle_help({
                    col_width = 45,
                    key_width = 10,
                    win = {
                      width = 60,
                      height = 0.6,
                      border = "rounded",
                      title = " Explorer Keymaps ",
                      position = "float",
                    },
                  })
                end,
              },
            },
          },
        },
      },
    },
    dashboard = {
      enabled = true,
    },
    bigfile = { enabled = true },
    -- Disabled - using Noice.nvim for notifications
    notifier = {
      enabled = false,
    },
    indent = { enabled = true },
    -- Disabled - using Noice.nvim for cmdline
    input = {
      enabled = true,
    },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    -- Disabled - using Noice.nvim for windows
    win = {
      enabled = false,
    },
    -- Disabled - using Noice.nvim for notifications
    styles = {
      notification = {
        enabled = false,
      },
    },
  },
}
