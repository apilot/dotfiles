return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "olimorris/neotest-rspec",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rspec")({
            rspec_cmd = function()
              return vim.iter({
                "bundle",
                "exec",
                "rspec",
              }):flatten():totable()
            end,
          }),
          -- Go adapter (neotest-golang, pulled by LazyVim lang.go extra).
          -- Uses `go test` under the hood; only activates for Go test files.
          require("neotest-golang")({}),
          -- Python adapter (neotest-python, pulled by LazyVim lang.python extra).
          -- Defaults to pytest; only activates for python test files.
          require("neotest-python")({}),
        },
      })
    end,
  },
}
