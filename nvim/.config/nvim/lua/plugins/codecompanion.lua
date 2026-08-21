-- CodeCompanion.nvim: AI chat / inline через локальную llama.cpp
-- Подключается напрямую к llama-server (без агента, plain chat)
-- Локальная модель должна быть запущена через `qwen-up` (3b по умолчанию на :8080)

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
            -- Локальная llama.cpp (Qwen2.5-Coder-3B)
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
          chat = { adapter = "llama_local" },
          inline = { adapter = "llama_local" },
          cmd = { adapter = "llama_local" },
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
      { "<leader>acc", "<cmd>CodeCompanionChat<cr>", mode = { "n", "v" }, desc = "AI Chat (local llama)" },
      { "<leader>aci", "<cmd>CodeCompanion<cr>",     mode = { "n", "v" }, desc = "AI Inline (local llama)" },
      { "<leader>aca", "<cmd>CodeCompanionActions<cr>",                desc = "AI Actions" },
    },
  },
}
