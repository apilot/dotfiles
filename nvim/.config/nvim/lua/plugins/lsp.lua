-- LSP and completion plugins
return {
  -- Enhanced LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        solargraph = {
          cmd = { "solargraph", "stdio" },
          settings = {
            solargraph = {
              formatting = false, -- Use StandardRB for formatting instead
              configPath = vim.fn.getcwd() .. "/.standard.yml",
              diagnostics = {
                enabled = true,
                exclude = { "rubocop" }, -- Disable RuboCop diagnostics
              },
              completion = true,
              signatures = true,
            },
          },
          on_attach = function(client, bufnr)
            -- Disable Solargraph formatting capability to use StandardRB
            client.server_capabilities.documentFormattingProvider = false
            vim.keymap.set("n", "<leader>lf", function()
              require("conform").format({ bufnr = bufnr })
            end, { buffer = bufnr, desc = "Format with Standard" })
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
        "standardrb",
        "hyprls",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
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
      },
    },
  },
}
