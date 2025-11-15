-- Aider utility functions for enhanced functionality
local M = {}

-- Toggle current file in aider
M.toggle_current_file = function()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.notify("No file to toggle", vim.log.levels.WARN)
    return
  end
  vim.cmd("AiderToggleFile " .. filepath)
end

-- Send current line to aider
M.send_line = function()
  local line = vim.api.nvim_get_current_line()
  if line == "" then
    vim.notify("No content to send", vim.log.levels.WARN)
    return
  end
  -- Copy line to register and send
  vim.cmd('let @z = "' .. line .. '"')
  vim.cmd("AiderSend")
end

-- Send visual selection to aider
M.send_selection = function()
  -- This is handled by the visual mode mapping
  vim.cmd("AiderSend")
end

-- Quick chat with current file context
M.quick_chat_with_file = function()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.cmd("AiderQuickChat")
  else
    -- First add current file, then open quick chat
    M.toggle_current_file()
    vim.cmd("AiderQuickChat")
  end
end

-- Add multiple files using fzf-lua
M.add_files_interactive = function()
  local fzf_lua = require("fzf-lua")
  fzf_lua.files(function(selected)
    if selected and #selected > 0 then
      for _, file in ipairs(selected) do
        vim.cmd("AiderToggleFile " .. file)
      end
      vim.notify("Added " .. #selected .. " files to Aider", vim.log.levels.INFO)
    end
  end)
end

-- Create user commands (only unique ones not provided by the plugin)
function M.setup_commands()
  -- Command to switch models
  vim.api.nvim_create_user_command("AiderSetModel", function(opts)
    if opts.args and opts.args ~= "" then
      vim.notify("Aider model set to: " .. opts.args, vim.log.levels.INFO)
      -- You can add logic here to update the global configuration
      vim.g.aider_model = opts.args
    else
      vim.notify("Please provide a model name: :AiderSetModel <model>", vim.log.levels.WARN)
    end
  end, {
    nargs = 1,
    complete = function()
      -- Provide common model suggestions
      return {
        "openai/qwen3-coder",
        "gpt-4o",
        "gpt-4o-mini",
        "claude-3-5-sonnet",
        "deepseek/deepseek-coder",
      }
    end,
    desc = "Set Aider model"
  })
end

return M