return {
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    lazy = false,
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    ---
    opts = {
      -- add any opts here
      -- this file can contain specific instructions for your project
      -- instructions_file = "avante.md",
      -- for example
      provider = "ollama",
      providers = {
        ollama = {
          -- __inherited_from = "openai",
          -- api_key_name = "",
          -- endpoint = "http://127.0.0.1:11434/v1",
          -- model = "qwen3-coder",
          -- -- model = "hir0rameel/qwen-claude",
          max_tokens = 16864,
          -- -- important to set this to true if you are using a local server
          disable_tools = true,
          -- extra_request_body = {
          --   stream = true,
          -- },
          endpoint = "http://localhost:11434",
          model = "qwen3-coder:latest",
          api_key = "ollama",
        },
      },
      -- providers = {
      --   ollama = {
      --     endpoint = "http://localhost:11434",
      --     model = "qwen3-coder",
      --     max_tokens = 4096,
      --     disable_tools = true,
      --   },
      -- },
    },
    behaviour = {
      auto_suggestions = false, -- Experimental stage
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = true,
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-mini/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
