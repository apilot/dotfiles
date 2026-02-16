-- Language specific configurations

-- Ruby: Auto-create .solargraph.yml for projects
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.rb", "*.rake", "Gemfile", "Rakefile", "config.ru", "*.erb" },
  once = true,
  callback = function()
    if vim.fs.root(".ruby-version", "Gemfile", ".git", "config.ru") then
      local root = vim.fs.root(".ruby-version", "Gemfile", ".git", "config.ru")
      local solargraph_config = root .. "/.solargraph.yml"

      -- Check if .solargraph.yml exists
      if vim.fn.filereadable(solargraph_config) == 0 then
        -- Create .solargraph.yml with minimal settings (no gem indexing)
        local content = [[# Solargraph configuration
# Disable gem indexing for performance

# Don't include gems in indexing
includeGems: false

# Ignore large directories
exclude:
  - "spec/**/*"
  - "test/**/*"
  - "tmp/**/*"
  - "log/**/*"
  - "vendor/**/*"
  - "node_modules/**/*"
  - "public/**/*"
  - "db/**/*"
  - ".git/**/*"
  - "storage/**/*"

# Max files to index
maxFiles: 5000

# Formatting disabled (using StandardRB)
formatting: false

# Diagnostics
diagnostics: true

# Features
completion: true
hover: true
signatures: true
definitions: true
references: true
rename: true
symbols: true
]]
        vim.fn.writefile(vim.split(content, "\n", { plain = true }), solargraph_config)
        vim.notify("Created .solargraph.yml (gem indexing disabled)", vim.log.levels.INFO, { title = "Solargraph" })
      end
    end
  end,
  desc = "Auto-create .solargraph.yml for Ruby projects"
})

-- Ruby: Keymaps for Solargraph
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "eruby" },
  callback = function()
    -- Restart Solargraph
    vim.keymap.set("n", "<leader>lR", function()
      require("config.ruby-solargraph").restart()
    end, {
      buffer = true,
      desc = "Restart Solargraph",
    })
  end,
  desc = "Ruby Solargraph keymaps"
})

-- Hyprland LSP configuration
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.hl", "hypr*.conf" },
  callback = function(event)
    vim.lsp.start({
      name = "hyprlang",
      cmd = { "hyprls" },
      root_dir = vim.fn.getcwd(),
    })
  end,
  desc = "Start Hyprland LSP for configuration files"
})

-- Ruby auto-formatting on save using StandardRB
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.rb", "*.rake", "Gemfile", "Rakefile", "config.ru" },
  callback = function()
    require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
  end,
  desc = "Auto-format Ruby files on save with StandardRB"
})

-- ERB (Rails views) auto-formatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.erb" },
  callback = function()
    require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
  end,
  desc = "Auto-format ERB files on save with htmlbeautifier + standardrb"
})

-- HAML auto-formatting on save (if used)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.haml" },
  callback = function()
    require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
  end,
  desc = "Auto-format HAML files on save with haml-lint"
})

-- SLIM auto-formatting on save (if used)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.slim" },
  callback = function()
    require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
  end,
  desc = "Auto-format SLIM files on save with slim-lint"
})

-- Additional language-specific autocmds can be added here