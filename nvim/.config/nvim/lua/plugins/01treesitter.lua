return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  branch = "main",
  lazy = false,
  build = function()
    -- Auto-install parsers on build
    local parsers = {
      "json", "javascript", "typescript", "tsx", "yaml",
      "html", "css", "prisma", "markdown", "markdown_inline",
      "svelte", "graphql", "bash", "lua", "vim", "dockerfile",
      "gitignore", "query", "vimdoc", "c", "ruby",
    }
    vim.cmd("TSInstallSync! " .. table.concat(parsers, " "))
  end,
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- Highlight and indent are handled natively by Neovim 0.12+
    -- via vim.treesitter.start() which is called automatically for
    -- filetypes with installed parsers.
    -- Treesitter indent can be enabled per-filetype if needed:
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
