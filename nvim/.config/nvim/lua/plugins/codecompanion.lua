-- CodeCompanion.nvim: AI chat / inline
-- Основной адаптер: Z.AI GLM (Coding Plan, glm-5-turbo — дешёвые правки/чат)
-- Офлайн-фолбэк: локальная llama.cpp через `qwen-up` (3b на :8080, 7b на :8081)

return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp",         -- completion в chat-буфере
      "ibhagwan/fzf-lua",         -- для action_palette
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    opts = function()
      return {
      adapters = {
        http = {
          -- Z.AI GLM через Coding Plan (токены с подписки)
          -- Внимание: flash-модели НЕ входят в Coding Plan (проверено 2026-08).
          -- Дешёвые модели плана: glm-5-turbo (осн.), glm-4.5-air (запас)
          zai = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                url = "https://api.z.ai/api/coding/paas/v4",
                api_key = "Z_AI_API_KEY",
                chat_url = "/chat/completions",
              },
              schema = {
                model = {
                  default = "glm-5-turbo",
                  order = 1,
                  -- Статичный список: валидация модели при отправке больше НЕ ходит
                  -- в сеть за GET /models (тот вызов падал ipairs(nil) при 1302 rate-limit)
                  choices = {
                    "glm-5-turbo", -- дешёвая, по умолчанию
                    "glm-4.5-air",  -- запасная дешёвая
                    "glm-4.7",      -- средний тир
                    "glm-5.3",      -- флагман (для сложных задач вручную)
                  },
                },
                temperature = { default = 0.1 },
                max_tokens = { default = 4096 },
              },
            })
          end,
          -- Локальная llama.cpp (Qwen2.5-Coder-3B) — офлайн-фолбэк
          llama_local = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                  url = "http://127.0.0.1:8080",
                  api_key = "TERM", -- llama.cpp не требует ключ, placeholder
                  chat_url = "/v1/chat/completions",
                },
                schema = {
                  model = { default = "qwen2.5-coder-3b", order = 1 },
                  temperature = { default = 0.1 },
                  max_tokens = { default = 4096 },
                },
              })
            end,
            -- Локальная 7B (если запущена через `qwen-up 7b` на :8081)
            llama_7b = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                  url = "http://127.0.0.1:8081",
                  api_key = "TERM",
                  chat_url = "/v1/chat/completions",
                },
                schema = {
                  model = { default = "qwen2.5-coder-7b", order = 1 },
                  temperature = { default = 0.1 },
                  max_tokens = { default = 2048 },
                },
              })
            end,
          },
        },
        -- NOTE: `strategies` was renamed to `interactions` (the old `agent`
        -- strategy no longer exists; it split into `cmd` + `background`).
        interactions = {
          chat = { adapter = "zai" },
          inline = { adapter = "zai" },
          cmd = { adapter = "zai" },
        },
        display = {
          chat = {
            window = {
              width = 0.4,
              position = "right",
            },
            show_settings = true,
            show_header_separator = false,
          },
          action_palette = {
            -- CodeCompanion не имеет встроенного fzf_lua провайдера,
            -- но #default использует vim.ui.select, который у нас перехвачен fzf-lua
            provider = "default",
          },
          diff = {
            enabled = true,
            close_chat_at = 240, -- закрыть чат при >240 lines diff
          },
        },
        opts = {
          language = "english",
          send_code = true,
          log_level = "ERROR",
        },
      }
    end,
    keys = {
      { "<leader>acc", "<cmd>CodeCompanionChat<cr>", mode = { "n", "v" }, desc = "AI Chat (GLM turbo)" },
      -- Инлайн с ГАРАНТИРОВАННЫМ контекстом (обход потери visual-режима через vim.ui.input):
      -- из visual — правка выделения (range=2 => маркы '<,'>), из normal — весь буфер (#{buffer})
      {
        "<leader>aci",
        function()
          local is_visual = vim.fn.mode():find("[vV\22]") ~= nil
          vim.ui.input({
            prompt = is_visual and "Inline (replace selection): " or "Inline (whole buffer): ",
          }, function(input)
            if not input or #vim.trim(input) == 0 then
              return
            end
            if is_visual then
              -- выйти из visual: маркы '< '> фиксируют выделение
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false
              )
              require("codecompanion").inline({ range = 2, args = input })
            else
              -- #{buffer}: полный контекст буфера независимо от режима
              require("codecompanion").inline({ args = "#{buffer} " .. input })
            end
          end)
        end,
        mode = { "n", "v" },
        desc = "AI Inline (selection/buffer)",
      },
      { "<leader>aca", "<cmd>CodeCompanionActions<cr>",                desc = "AI Actions" },
    },
  },
}
