-- Copilot configuration with availability check

local M = {}

-- Variables to track Copilot state
local copilot_disabled = false
local copilot_message_shown = false

-- Function to disable Copilot plugin
local function disable_copilot(reason)
  if copilot_disabled then
    return -- Already disabled
  end

  -- Disable Copilot completely
  vim.g.copilot_enabled = 0
  vim.g.copilot_assume_mapped = true
  vim.g.copilot_no_tab_map = true

  -- Prevent Copilot from starting
  vim.g.loaded_copilot = 1
  vim.g.loaded_copilot_cmp = 1
  vim.g.loaded_copilot_lua = 1

  -- Clear Copilot autocmds if they exist
  if vim.g.copilot_autocmds_created then
    vim.api.nvim_clear_autocmds({ group = "Copilot" })
    vim.g.copilot_autocmds_created = false
  end

  copilot_disabled = true

  -- Show message only once per session
  if not copilot_message_shown then
    print("Copilot: " .. reason .. " - plugin disabled")
    copilot_message_shown = true
  end
end

-- Function to check for "Copilot is not available in your location" message
local function check_copilot_unavailable_message()
  -- This will be called from autocmd when Copilot shows the unavailable message
  return vim.g.copilot_unavailable_detected == true
end

-- Function to check if Copilot server is reachable (fallback method)
local function check_copilot_server()
  -- Simple check - try to reach GitHub API
  local handle = io.popen("curl -s --connect-timeout 2 --max-time 2 https://api.github.com > /dev/null 2>&1; echo $?", "r")
  if not handle then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  return result:match("^0$") ~= nil
end

-- Function to configure Copilot based on availability
local function configure_copilot_based_on_availability()
  -- Check for manual override in environment variables
  local force_enable = vim.env.CPILOT_FORCE_ENABLE == "1"
  local force_disable = vim.env.CPILOT_FORCE_DISABLE == "1"

  if force_enable then
    -- Force enable regardless of availability
    vim.g.copilot_enabled = 1
    vim.g.copilot_assume_mapped = false
    vim.g.copilot_no_tab_map = false
    copilot_disabled = false
    print("Copilot: Force enabled via CPILOT_FORCE_ENABLE")
    return
  end

  if force_disable then
    -- Force disable regardless of availability
    disable_copilot("Force disabled via CPILOT_FORCE_DISABLE")
    return
  end

  -- Check if the unavailable message was detected
  if check_copilot_unavailable_message() then
    disable_copilot("Not available in your location")
    return
  end

  -- Fallback: check server connectivity
  if not check_copilot_server() then
    disable_copilot("Server not reachable")
    return
  end

  -- If we reach here, Copilot should be available
  vim.g.copilot_enabled = 1
  vim.g.copilot_assume_mapped = false
  vim.g.copilot_no_tab_map = false
  copilot_disabled = false

  -- Only show enable message if it wasn't disabled before
  if not copilot_message_shown then
    print("Copilot: Plugin enabled")
  end
end

-- Set up autocmd to detect Copilot unavailable message
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      configure_copilot_based_on_availability()
    end, 3000) -- Wait for Copilot to initialize
  end,
  desc = "Check Copilot availability after startup"
})

-- Override vim.notify to catch Copilot messages
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  original_notify(msg, level, opts)

  if msg and type(msg) == "string" and msg:match("Copilot is not available in your location") then
    vim.g.copilot_unavailable_detected = true
    vim.schedule(function()
      configure_copilot_based_on_availability()
    end)
  end
end

-- Simple check on BufEnter for better performance
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    -- Only check if we haven't already detected unavailability
    if vim.g.copilot_unavailable_detected then
      return
    end

    -- Only check in normal buffers (not terminal, help, etc.)
    local buftype = vim.api.nvim_get_option_value("buftype", {})
    if buftype ~= "" then
      return
    end

    -- Check last few lines for the Copilot message
    local buf = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(buf)
    if line_count > 0 then
      local start_line = math.max(0, line_count - 5)
      local lines = vim.api.nvim_buf_get_lines(buf, start_line, -1, false)
      for _, line in ipairs(lines) do
        if line:match("Copilot is not available in your location") then
          vim.g.copilot_unavailable_detected = true
          vim.schedule(function()
            configure_copilot_based_on_availability()
          end)
          break
        end
      end
    end
  end,
  desc = "Detect Copilot unavailable message on buffer enter"
})

-- Function to manually recheck Copilot status
function M.recheck_copilot()
  vim.g.copilot_unavailable_detected = false
  configure_copilot_based_on_availability()
end

-- Function to check current Copilot status
function M.status()
  if copilot_disabled then
    return "disabled"
  elseif vim.g.copilot_enabled == 1 then
    return "enabled"
  else
    return "disabled"
  end
end

-- Function to get server availability
function M.is_server_available()
  return not copilot_disabled and vim.g.copilot_enabled == 1
end

-- Create user commands
vim.api.nvim_create_user_command("CopilotRecheck", function()
  M.recheck_copilot()
end, { desc = "Recheck Copilot availability" })

vim.api.nvim_create_user_command("CopilotStatus", function()
  local status = M.status()
  local available = M.is_server_available()
  local status_text = available and "available" or "not available"
  print(string.format("Copilot: %s (%s)", status, status_text))
end, { desc = "Show Copilot status and availability" })

-- Auto-recheck when focusing Neovim
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    -- Only recheck if it's been more than 5 minutes since last check
    local last_check = vim.g.copilot_last_check or 0
    local now = os.time()
    if now - last_check > 300 then
      vim.g.copilot_last_check = now
      vim.schedule(function()
        M.recheck_copilot()
      end)
    end
  end,
  desc = "Recheck Copilot availability on focus gain"
})

-- Update last check time
vim.g.copilot_last_check = os.time()

return M