
require('barbar').setup {
    auto_hide = false,
    tabpages = true,
    closable = true,
    clickable = true,
    exclude_ft = {'javascript'},
    exclude_name = {'package.json'},
    sidebar_filetypes = {
      NvimTree = true,
      Outline = {event = 'BufWinLeave', text = 'symbols-outline'},
    },
    icons = {
        filetype = {
        enabled = true
        },
      },
      no_name_title = nil,
  }

require('tabnine').setup({
  disable_auto_comment=true,
  accept_keymap="<C-`>",
  dismiss_keymap = "<C-]>",
  debounce_ms = 800,
  suggestion_color = {gui = "#808080", cterm = 244},
  exclude_filetypes = {"TelescopePrompt", "NvimTree"},
  log_file_path = nil, -- absolute path to Tabnine log file
})

local configs = require("nvim-treesitter.configs")
configs.setup {
  -- Add a language of your choice
  ensure_installed = {"ruby","cpp", "python", "lua", "java", "javascript", "embedded_template"},
  sync_install = false,
  ignore_install = { "" }, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "" }, -- list of language that will be disabled
    additional_vim_regex_highlighting = true,

  },
  indent = { enable = true, disable = { "yaml" } },
  rainbow = {
    enable = true,
    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
    -- colors = {}, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
  }
}
require('gitsigns').setup()
require("ibl").setup()
require("neotest").setup({
  adapters = {
    require("neotest-rspec")({
      rspec_cmd = function()
        return vim.tbl_flatten({
          "bundle",
          "exec",
          "rspec",
        })
      end
    }),
  },
})
require("git-worktree").setup()
require("telescope").load_extension("git_worktree")
require("telescope").load_extension("live_grep_args")

vim.opt.signcolumn = "yes" -- otherwise it bounces in and out, not strictly needed though

