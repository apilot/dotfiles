-- AI and code generation plugins
return {
  -- Aider.nvim - AI pair programming assistant
  {
    "joshuavial/aider.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      -- Default model to use
      model = "openai/qwen3-coder",
      -- Auto-focus aider window when opened
      auto_focus = true,
      -- Window configuration for floating aider
      window = {
        width = 0.85,
        height = 0.85,
        border = "rounded",
      },
      -- Additional aider options
      args = {
        "--no-auto-commits",
        "--yes-always",
        "--dark-mode",
        "--chat-language",
        "ru",
      },
      border = {
        style = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }, -- or e.g. "rounded"
        color = "#fab387",
      },
    },
    keys = {
      { "<leader>aa", "<cmd>AiderOpen<cr>", mode = { "n", "v" }, desc = "Open Aider" },
      { "<leader>am", "<cmd>AiderAddModifiedFiles<cr>", mode = { "n" }, desc = "Add modified files" },
    },
    cmd = { "AiderOpen", "AiderAddModifiedFiles" },
    config = function(_, opts)
      require("aider").setup(opts)

      -- Setup utility commands
      require("utils.aider").setup_commands()

      -- Create alias command after plugin is loaded
      vim.defer_fn(function()
        vim.api.nvim_create_user_command("Aider", function()
          vim.cmd("AiderOpen")
        end, { desc = "Alias for AiderOpen" })

        vim.api.nvim_create_user_command("AiderAddFiles", function()
          require("fzf-lua").files(function(selected)
            if selected and #selected > 0 then
              -- First open aider if not already open
              local aider = require("aider")
              if not aider.aider_buf or not vim.api.nvim_buf_is_valid(aider.aider_buf) then
                aider.AiderOpen()
                vim.defer_fn(function()
                  -- Add files to aider
                  for _, file in ipairs(selected) do
                    vim.fn.chansend(aider.aider_job_id, "/add " .. file .. "\n")
                  end
                  vim.notify("Added " .. #selected .. " files to Aider", vim.log.levels.INFO)
                end, 1000)
              else
                -- Aider is already open, add files directly
                for _, file in ipairs(selected) do
                  vim.fn.chansend(aider.aider_job_id, "/add " .. file .. "\n")
                end
                vim.notify("Added " .. #selected .. " files to Aider", vim.log.levels.INFO)
              end
            end
          end)
        end, { desc = "Add files to Aider using fzf-lua" })
      end, 100)
    end,
  },

  -- General AI assistant
  {
    "David-Kunz/gen.nvim",
    cmd = { "Gen", "GenChat", "GenSelect" },
    opts = {
      model = "mistral", -- default model
      host = "localhost",
      port = "11434",
      display_mode = "float",
      show_prompt = true,
      show_model = true,
      no_auto_close = false,
      init = function(options) end,
      command = function(options)
        return "curl --silent --no-buffer -X POST http://"
          .. options.host
          .. ":"
          .. options.port
          .. "/api/generate -d $body"
      end,
      debug = false,
    },
    keys = {
      { "<leader>ag", ":Gen<cr>", mode = { "n", "v" }, desc = "Generate with Gen" },
      { "<leader>gc", ":GenChat<cr>", mode = { "n" }, desc = "Gen Chat" },
    },
  },
}
