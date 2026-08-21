return {
  {
    "stevearc/conform.nvim",
    opts = {
      default_format_opts = {
        timeout_ms = 10000, -- Increased from 3000 to handle larger Ruby files
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_format = "prefer", -- not recommended to change
      },
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        ruby = { "rubyfmt" }, -- Ruby via rubyfmt (Rust, opinionated); ruby_lsp formatting disabled in lsp.lua
        -- ERB (.erb): formatter chosen per-buffer. erb-format (nebulab gem) is
        -- the primary: it formats HTML structure, ERB tag delimiters AND the
        -- Ruby inside <% %>, including correct indentation of ruby blocks
        -- (if/do/end) ACROSS tags -- something rubyfmt via conform "injected"
        -- cannot do (each <% %> is an incomplete fragment). BUT erb-format 0.7.3
        -- CRASHES on views containing a <script> block: its HTML parser
        -- mis-tokenizes the JavaScript ("Bad attribute, please fix spaces after
        -- the equal sign"; known limitation in their roadmap). For such buffers
        -- fall back to herb-format (@herb-tools), a real HTML/ERB parser that
        -- treats <script> content as opaque text and never crashes. Trade-off:
        -- herb only formats HTML structure + delimiters, NOT the Ruby deeply;
        -- and the Ruby style is erb-formatter's (not rubyfmt's) for the primary.
        eruby = function(bufnr)
          for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
            if line:match("<script") then
              return { "herb_format" }
            end
          end
          return { "erb_format" }
        end,
        markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
        ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
      },
      -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
          end,
        },
        ["markdownlint-cli2"] = {
          prepend_args = { "--config", vim.fn.expand("~/.config/nvim/.markdownlint.json") },
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
        -- ERB formatter (nebulab erb-formatter gem). Use the DIRECT install path
        -- under the global-default ruby, NOT the mise shim: the shim resolves the
        -- ruby version per-CWD, so in a Rails project whose .ruby-version pins a
        -- ruby without the erb-format gem it errors "No version is set for shim:
        -- erb-format". The direct binary always runs the global ruby's erb-format
        -- regardless of the project's ruby (the formatter only rewrites ERB text,
        -- it does not execute project code). Mirrors the herb_format/rubyfmt
        -- direct-path pinning; update the version segment if the global ruby
        -- changes. Built-in supplies args = { "--stdin" }.
        erb_format = {
          -- Invoke the gem wrapper with an EXPLICIT ruby interpreter (the global
          -- default 3.4.10) instead of relying on the wrapper's "#!/usr/bin/env
          -- ruby" shebang. The shebang resolves `ruby` from PATH, which inside a
          -- Rails project is the PROJECT's ruby (e.g. 3.4.5 via .ruby-version);
          -- that ruby lacks the erb-formatter gem (installed only under 3.4.10),
          -- so the wrapper crashes with "can't find gem erb-formatter". Forcing
          -- the 3.4.10 ruby makes formatting deterministic regardless of project
          -- ruby (the formatter only rewrites ERB text, it does not run project
          -- code). Update both version segments if the global ruby changes.
          command = vim.fn.expand("~/.local/share/mise/installs/ruby/3.4.10/bin/ruby"),
          args = {
            vim.fn.expand("~/.local/share/mise/installs/ruby/3.4.10/bin/erb-format"),
            "--stdin",
          },
        },
        -- Fallback ERB formatter for views erb-format can't handle (see the
        -- per-buffer eruby selection above). herb-format (@herb-tools/formatter,
        -- Node) is a real HTML/ERB parser: it treats <script> content as opaque
        -- text, so it never crashes on embedded JavaScript (unlike erb-format
        -- 0.7.3). It formats HTML structure + ERB delimiters but does NOT deeply
        -- format the Ruby inside <% %>. Reads stdin via "-" and writes formatted
        -- output to stdout. Pin the node install path (mirrors erb_format/
        -- rubyfmt); update the version segment if the global node changes.
        -- NOTE: herb prints an "Experimental Preview" warning to stderr; conform
        -- uses stdout only, so it is harmless (just noise in conform.log).
        herb_format = {
          command = vim.fn.expand("~/.local/share/mise/installs/node/22.13.0/bin/herb-format"),
          args = { "-" },
        },
        -- Ruby formatter (rubyfmt, Rust). Binary ships as "rubyfmt-main"
        -- (Cargo package name); conform's built-in expects bare "rubyfmt"
        -- which won't resolve. Pin absolute cargo path: nvim launched without
        -- cargo bin on PATH (GUI launch) can't find it otherwise.
        rubyfmt = {
          command = vim.fn.expand("~/.cargo/bin/rubyfmt-main"),
          stdin = true,
        },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
      },
    },
  },
  -- Disable none-ls markdownlint diagnostics (we use nvim-lint instead)
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local null_ls = require("null-ls")
      opts.sources = opts.sources or {}
      -- Remove markdownlint_cli2 from none-ls sources
      opts.sources = vim.tbl_filter(function(source)
        return source.name ~= "markdownlint_cli2"
      end, opts.sources)
      -- Also prevent it from being registered by returning a modified setup
    end,
  },
  -- Filter unwanted markdownlint rules from diagnostics
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = {
            "--config",
            vim.fn.expand("~/.config/nvim/.markdownlint.json"),
            "-",
          },
        },
      },
      linters_by_ft = {
        markdown = { "markdownlint-cli2" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    event = "VeryLazy",
    config = function()
      local ignored_rules = { ["MD013/"] = true, ["MD024/"] = true, ["MD036"] = true, ["MD040/"] = true, ["MD060/"] = true }
      local group = vim.api.nvim_create_augroup("filter_markdownlint", { clear = true })
      local filtering = false
      vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = group,
        callback = function(ev)
          if filtering then return end
          local diags = ev.data.diagnostics
          if not diags or #diags == 0 then
            return
          end
          -- Only filter markdownlint diagnostics
          local has_filtered = false
          local filtered = {}
          for _, d in ipairs(diags) do
            local skip = false
            if d.source and (d.source == "markdownlint" or d.source == "markdownlint-cli2") then
              for rule in pairs(ignored_rules) do
                if d.message:find(rule, 1, true) then
                  skip = true
                  has_filtered = true
                  break
                end
              end
            end
            if not skip then
              filtered[#filtered + 1] = d
            end
          end
          if has_filtered then
            filtering = true
            -- Reset ALL namespaces for this buffer, then set filtered for each
            for id, ns in pairs(vim.diagnostic.get_namespaces()) do
              local buf_diags = vim.diagnostic.get(ev.buf, { ns_id = id })
              if #buf_diags > 0 then
                local ns_filtered = vim.tbl_filter(function(d)
                  if d.source and (d.source == "markdownlint" or d.source == "markdownlint-cli2") then
                    for rule in pairs(ignored_rules) do
                      if d.message:find(rule, 1, true) then return false end
                    end
                  end
                  return true
                end, buf_diags)
                vim.diagnostic.reset(id, ev.buf)
                vim.diagnostic.set(id, ev.buf, ns_filtered)
              end
            end
            filtering = false
          end
        end,
      })
    end,
  },
}
