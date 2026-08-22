-- AI and code generation plugins
return {
  -- Aider.nvim - хирургические правки (GLM через Coding Plan)
  -- Модель/endpoint/auto-commits настраиваются в ~/.aider.conf.yml + ~/.env
  {
    "joshuavial/aider.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      -- Совпадает с ~/.aider.conf.yml (main), иначе переопределит конфиг
      model = "openai/glm-5.3",
      -- Auto-focus aider window when opened
      auto_focus = true,
      -- Window configuration for floating aider
      window = {
        width = 0.85,
        height = 0.85,
        border = "rounded",
      },
      -- НЕ передаём model/commits args: единый источник правды ~/.aider.conf.yml
      args = {
        "--dark-mode",
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
}
