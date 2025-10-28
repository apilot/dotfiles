-- Language specific configurations

-- Hyprland LSP configuration
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.hl", "hypr*.conf" },
  callback = function(event)
    vim.lsp.start({
      name = "hyprlang",
      cmd = { "hyprls" },
      root_dir = vim.fn.getcwd(),
    })
  end,
  desc = "Start Hyprland LSP for configuration files"
})

-- Ruby auto-formatting on save using StandardRB
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rb",
  callback = function()
    require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
  end,
  desc = "Auto-format Ruby files on save with StandardRB"
})

-- Additional language-specific autocmds can be added here