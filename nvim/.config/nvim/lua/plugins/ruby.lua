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
-- - ruby-lsp (Shopify) is the Ruby LSP server
-- - ruby-lsp-rails for Rails-specific features
-- - Uses rbenv for Ruby version management
-- - Auto-installs ruby-lsp gem if missing for current rbenv version
-- - StandardRB is used for formatting (via conform.nvim)
-- - Keymaps:
--   - `<leader>lR` - Restart Ruby LSP
--   - `<leader>lI` - Install ruby-lsp gems
