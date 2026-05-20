-- Ruby LSP configuration (ruby-lsp gem by Shopify)

local M = {}

-- Check if ruby-lsp gem is installed for current rbenv version
function M.is_installed()
  local result = vim.fn.system("gem list -i ruby-lsp 2>/dev/null")
  return vim.v.shell_error == 0 and vim.trim(result) == "true"
end

-- Install ruby-lsp + ruby-lsp-rails gems
function M.install_gems()
  vim.notify("Installing ruby-lsp + ruby-lsp-rails...", vim.log.levels.INFO, { title = "Ruby LSP" })
  local output = vim.fn.system("gem install ruby-lsp ruby-lsp-rails 2>&1")
  if vim.v.shell_error == 0 then
    vim.notify("ruby-lsp installed successfully!", vim.log.levels.INFO, { title = "Ruby LSP" })
    -- Start the LSP after install
    vim.defer_fn(function()
      vim.cmd("LspStart ruby_lsp")
    end, 200)
    return true
  else
    vim.notify("Failed to install ruby-lsp:\n" .. output, vim.log.levels.ERROR, { title = "Ruby LSP" })
    return false
  end
end

-- Prompt user to install if not available
function M.ensure_installed()
  if not M.is_installed() then
    vim.ui.select(
      { "Install ruby-lsp + ruby-lsp-rails", "Skip" },
      { prompt = "ruby-lsp gem not found for current Ruby version. " },
      function(choice)
        if choice and choice:find("Install") then
          M.install_gems()
        else
          vim.notify("Ruby LSP disabled for this session", vim.log.levels.WARN, { title = "Ruby LSP" })
        end
      end
    )
  end
end

-- Restart Ruby LSP
function M.restart()
  local bufnr = vim.api.nvim.get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "ruby_lsp" })

  for _, client in ipairs(clients) do
    client:stop(true)
  end

  vim.defer_fn(function()
    vim.cmd("LspStart ruby_lsp")
    vim.notify("Ruby LSP restarted", vim.log.levels.INFO, { title = "Ruby LSP" })
  end, 100)
end

return M
