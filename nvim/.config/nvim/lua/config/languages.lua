-- Language specific configurations

-- Ruby: Check ruby-lsp availability on FileType
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "eruby" },
  once = true,
  callback = function()
    require("config.ruby-lsp").ensure_installed()
  end,
  desc = "Check ruby-lsp gem availability for current rbenv version",
})

-- Ruby: Keymaps for Ruby LSP
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "eruby" },
  callback = function()
    -- Restart Ruby LSP
    vim.keymap.set("n", "<leader>rR", function()
      require("config.ruby-lsp").restart()
    end, {
      buffer = true,
      desc = "Restart Ruby LSP",
    })
    -- Install ruby-lsp gems
    vim.keymap.set("n", "<leader>rI", function()
      require("config.ruby-lsp").install_gems()
    end, {
      buffer = true,
      desc = "Install ruby-lsp gems",
    })
  end,
  desc = "Ruby LSP keymaps",
})

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

-- Ruby / ERB / HAML / SLIM auto-formatting on save is handled ONCE by
-- conform.nvim's built-in `format_on_save` (LazyVim default), which reads the
-- `formatters_by_ft` table in plugins/conform.lua (ruby -> rubyfmt, eruby ->
-- erb_format/herb_format). Do NOT add per-ft BufWritePre autocmds here: they
-- would duplicate conform's hook and format twice on every save.

-- Additional language-specific autocmds can be added here