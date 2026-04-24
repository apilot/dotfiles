-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Additional custom autocmds can be added here as the configuration grows
-- Language-specific autocmds have been moved to languages.lua

-- Set NVIM env for lazygit terminal so `e` opens files in current instance
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*lazygit*",
  callback = function()
    vim.env.NVIM = vim.v.servername
  end,
})

-- Lazygit edit handler: close float, open file in current window (no tabs)
function _G.lazygit_edit()
  local f = io.open("/tmp/lg-edit-file", "r")
  if not f then
    return ""
  end
  local file = f:read("*a"):gsub("\n", "")
  f:close()
  if file == "" then
    return ""
  end
  -- Close the lazygit float window
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("lazygit") then
        pcall(vim.api.nvim_win_close, win, true)
        break
      end
    end
  end
  -- Open file in the current window
  vim.cmd("edit " .. vim.fn.fnameescape(file))
  return ""
end
