-- fzf-lua configuration
return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      -- File operations
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
      -- Additional useful fzf commands
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
      { "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
      { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
    },
    config = function()
      require("fzf-lua").setup({
        "telescope",
        winopts = {
          height = 0.90,
          width = 0.85,
          preview = {
            border = "border",
            wrap = "nowrap",
            hidden = "nohidden",
            vertical = "down:45%",
            horizontal = "right:60%",
            layout = "flex",
            flip_columns = 120,
            title = true,
            title_pos = "center",
            scrollbar = "border",
          },
        },
        fzf_colors = {
          ["fg"] = { "fg", "Normal" },
          ["bg"] = { "bg", "Normal" },
          ["hl"] = { "fg", "String" },
          ["fg+"] = { "fg", "Normal" },
          ["bg+"] = { "bg", "CursorLine" },
          ["hl+"] = { "fg", "String" },
          ["info"] = { "fg", "Comment" },
          ["prompt"] = { "fg", "Identifier" },
          ["pointer"] = { "fg", "Keyword" },
          ["marker"] = { "fg", "Keyword" },
          ["spinner"] = { "fg", "Label" },
          ["header"] = { "fg", "Comment" },
        },
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "target/",
          ".vscode/",
          ".idea/",
        },
        grep = {
          rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=4096",
        },
      })
    end,
  },
}