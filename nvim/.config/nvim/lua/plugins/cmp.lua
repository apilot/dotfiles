return {
  {
    "tzachar/cmp-tabnine",
    build = "./install.sh",
    event = "InsertEnter",
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      opts.sources = cmp.config.sources({
        { name = "lazydev", group_index = 0 },
        { name = "nvim_lsp", priority = 1000, group_index = 1 },
        { name = "cmp_tabnine", priority = 900, group_index = 1 },
        { name = "snippets", priority = 800, group_index = 1 },
        { name = "path", priority = 500, group_index = 1 },
        { name = "buffer", priority = 250, keyword_length = 2, group_index = 1 },
        { name = "emoji", priority = 100, group_index = 1 },
      })

      opts.mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Esc>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.abort()
          else
            fallback()
          end
        end, { "i", "s" }),
      })

      opts.snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      }

      cmp.setup.cmdline({ '/', '?' }, {
        completion = { autocomplete = false },
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        completion = { autocomplete = false },
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end,
  },
}