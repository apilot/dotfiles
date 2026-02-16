-- Ruby and Rails specific plugins
return {
  -- Rails navigation and tools
  {
    "tpope/vim-rails",
    ft = { "ruby", "eruby" },
    dependencies = {
      "tpope/vim-projectionist",
    },
  },

  -- Ruby syntax highlighting improvements
  {
    "vim-ruby/vim-ruby",
    ft = { "ruby", "eruby" },
  },
}

-- Ruby LSP Configuration:
-- - Solargraph is the only Ruby LSP server
-- - Uses rbenv for Ruby version management
-- - Gem indexing is disabled for performance
-- - StandardRB is used for formatting
-- - Keymaps:
--   - `<leader>lR` - Restart Solargraph
