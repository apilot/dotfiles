-- Ruby Solargraph configuration
-- Solargraph is the only Ruby LSP server

local M = {}

-- Function to restart Solargraph
function M.restart()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "solargraph" })

  for _, client in ipairs(clients) do
    if client.id then
      vim.lsp.stop_client(client.id, true)
    end
  end

  vim.defer_fn(function()
    vim.cmd("LspStart solargraph")
    vim.notify("Solargraph restarted", vim.log.levels.INFO, { title = "Solargraph" })
  end, 100)
end

return M
