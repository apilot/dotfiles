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
      },
    },
  },

  -- Mason for managing LSP servers
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    -- Filter out Ruby gems that LazyVim's lang.ruby extra auto-installs via
    -- Mason (erb-formatter, erb-lint). We manage Ruby tooling through mise
    -- shims instead (see conform.lua `erb_format` pin and `ruby_lsp` mason=false
    -- above). Mason's gem copies bake a Ruby-version-specific shebang and go
    -- stale/broken when the Ruby version changes (e.g. the rbenv 3.3.6 shebang
    -- error after switching to mise). opts is a function so it runs AFTER
    -- LazyVim merges the extra's ensure_installed, letting us strip these.
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return pkg ~= "erb-formatter" and pkg ~= "erb-lint"
      end, opts.ensure_installed)
      -- Ensure the baseline tools are present even after filtering.
      for _, pkg in ipairs({ "stylua", "shfmt", "hyprls", "lua-language-server" }) do
        if not vim.tbl_contains(opts.ensure_installed, pkg) then
          table.insert(opts.ensure_installed, pkg)
        end
      end
      return opts
    end,
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
        { "<leader>t", group = "test/terminal" },
        { "<leader>u", group = "ui" },
        { "<leader>l", group = "lsp" },
      },
    },
  },
}
