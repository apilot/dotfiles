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
-- - ruby-lsp (Shopify) is the Ruby LSP server (managed via mise shim, see plugins/lsp.lua)
-- - ruby-lsp-rails for Rails-specific features (auto-installed add-on)
-- - ruby_lsp provides intelligence only; formatting is done by rubyfmt via
--   conform.nvim (formatters_by_ft.ruby = { "rubyfmt" })
-- - Keymaps (see config/languages.lua, buffer-local on ruby/eruby FileType):
--   - `<leader>rR` - Restart Ruby LSP
--   - `<leader>rI` - Install ruby-lsp gems
