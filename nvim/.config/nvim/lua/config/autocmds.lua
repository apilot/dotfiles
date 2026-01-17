-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Additional custom autocmds can be added here as the configuration grows
-- Language-specific autocmds have been moved to languages.lua

-- Автокоманды для улучшения работы автодополнения
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    -- Принудительно запускаем автодополнение при входе в режим вставки
    vim.schedule(function()
      local cmp = require("cmp")
      if not vim.fn.pumvisible() then
        cmp.complete()
      end
    end)
  end,
  desc = "Force completion on InsertEnter",
})

vim.api.nvim_create_autocmd("TextChangedI", {
  callback = function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    -- Проверяем, достаточно ли символов для автодополнения
    if col > 0 and line:sub(col, col):match("[%w_]") then
      local word_start = col
      while word_start > 1 and line:sub(word_start - 1, word_start - 1):match("[%w_]") do
        word_start = word_start - 1
      end

      local word_len = col - word_start + 1
      if word_len >= 1 then
        vim.schedule(function()
          local cmp = require("cmp")
          if not vim.fn.pumvisible() then
            cmp.complete()
          end
        end)
      end
    end
  end,
  desc = "Trigger completion on text change",
})
