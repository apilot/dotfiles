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
        solargraph = {
          cmd = { "rbenv", "exec", "solargraph", "stdio" },
          filetypes = { "ruby", "eruby" },
          root_dir = vim.fs.root(".ruby-version", "Gemfile", ".git", "config.ru"),
          autostart = true,
          settings = {
            solargraph = {
              formatting = false,
              diagnostics = { enabled = true },
              completion = true,
              signatures = true,
              definitions = true,
              references = true,
              rename = true,
              symbols = true,
              useBundler = false,
              includeGems = false,
            },
          },
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
        exclude = { "solargraph" },
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
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
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
        { "<leader>t", group = "terminal" },
        { "<leader>u", group = "ui" },
        { "<leader>l", group = "lsp" },
      },
    },
  },
}
