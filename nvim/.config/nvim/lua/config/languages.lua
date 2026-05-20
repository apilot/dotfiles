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

-- Ruby auto-formatting on save using StandardRB
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.rb", "*.rake", "Gemfile", "Rakefile", "config.ru" },
  callback = function()
    require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
  end,
  desc = "Auto-format Ruby files on save with StandardRB"
})

-- ERB (Rails views) auto-formatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.erb" },
  callback = function()
    require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
  end,
  desc = "Auto-format ERB files on save with htmlbeautifier + standardrb"
})

-- HAML auto-formatting on save (if used)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.haml" },
  callback = function()
    require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
  end,
  desc = "Auto-format HAML files on save with haml-lint"
})

-- SLIM auto-formatting on save (if used)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.slim" },
  callback = function()
    require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
  end,
  desc = "Auto-format SLIM files on save with slim-lint"
})

-- Additional language-specific autocmds can be added here