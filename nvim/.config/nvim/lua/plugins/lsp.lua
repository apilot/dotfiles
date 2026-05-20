-- LSP and completion plugins
return {
  -- Enhanced LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      servers = {
        -- Lua LSP for Neovim configuration
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
                path = vim.split(package.path, ";"),
              },
              diagnostics = {
                globals = { "vim", "LazyVim" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },
        ruby_lsp = {
          mason = false,
          init_options = { formatter = "none" },
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            vim.keymap.set("n", "<leader>lf", function()
              require("conform").format({ bufnr = bufnr })
            end, { buffer = bufnr, desc = "Format with Standard" })
          end,
        },
      },
    },
  },

  -- Mason-lspconfig bridge (disable automatic_enable for servers we manage via rbenv)
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_enable = {
        exclude = { "ruby_lsp" },
      },
    },
  },

  -- Mason for managing LSP servers
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "hyprls",
        "lua-language-server",
      },
    },
  },

  -- Which key for showing keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>c", group = "code" },
        { "<leader>f", group = "file" },
        { "<leader>g", group = "git" },
        { "<leader>w", group = "window" },
        { "<leader>E", group = "encoding" },
        { "<leader>C", group = "csv" },
        { "<leader>S", group = "session" },
        { "<leader>t", group = "terminal" },
        { "<leader>u", group = "ui" },
        { "<leader>l", group = "lsp" },
      },
    },
  },
}
