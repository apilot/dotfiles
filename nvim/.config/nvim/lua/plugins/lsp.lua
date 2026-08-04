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
          -- Pin the cmd to the mise shim so the correct Ruby version + bundle
          -- context is used per-project regardless of how nvim was launched.
          -- Do NOT use `bundle exec ruby-lsp` (ruby-lsp uses a composed bundle).
          cmd = { vim.fn.expand("~/.local/share/mise/shims/ruby-lsp") },
          init_options = {
            formatter = "none", -- formatting handled by rubyfmt via conform.nvim
            -- Explicit Rails add-on configuration. The add-on auto-installs on
            -- Rails projects, but pinning its settings makes behavior predictable.
            addonSettings = {
              ["Ruby LSP Rails"] = {
                enablePendingMigrationsPrompt = true,
              },
            },
          },
          on_attach = function(client, bufnr)
            -- ruby_lsp provides intelligence only; formatting is done by rubyfmt
            -- via conform.nvim. Disable both formatting providers so conform owns it.
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            vim.keymap.set("n", "<leader>lf", function()
              require("conform").format({ bufnr = bufnr })
            end, { buffer = bufnr, desc = "Format (rubyfmt)" })
          end,
        },
        -- HTML-aware ERB Language Server (installed globally via npm)
        -- Built-in config ships in nvim-lspconfig v2 (lsp/herb_ls.lua).
        -- Formatting is handled by herb-format via conform.nvim (mirror ruby_lsp/standardrb).
        herb_ls = {
          mason = false,
          -- Pin cmd to mise install bin so it resolves regardless of how nvim is
          -- launched (mirrors ruby_lsp; bare "herb-language-server" is not on PATH
          -- when nvim starts from a GUI/non-mise context).
          cmd = {
            vim.fn.expand("~/.local/share/mise/installs/node/22.13.0/bin/herb-language-server"),
            "--stdio",
          },
          on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
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
