-- fzf-lua configuration
return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      -- Additional LSP operations (not in keymaps.lua)
      { "<leader>lt", "<cmd>FzfLua lsp_typedefs<cr>", desc = "LSP Type Definitions" },
      { "<leader>ls", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document Symbols" },
      { "<leader>lS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },
      { "<leader>le", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
      { "<leader>lE", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
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
        -- LSP specific configuration
        lsp = {
          jump_to_single_result = true,
          jump_to_single_result_action = require("fzf-lua.actions").file_edit,
          async_or_timeout = 3000,
          code_actions = {
            async_or_timeout = 5000,
            ui_select = true,
          },
          diagnostics = {
            severity_limit = "Hint",
            multiline = true,
            path_shorten = 1,
          },
          symbols = {
            async_or_timeout = 4000,
            symbol_hl = function(s)
              return vim.lsp.protocol.SymbolKind[s.kind] or "Unknown"
            end,
            symbol_fmt = function(s)
              return ("[%s] %s"):format(s.kind, s.name)
            end,
            child_prefix = true,
          },
        },
      })
    end,
  },
}