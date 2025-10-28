-- AI and code generation plugins
return {
  -- General AI assistant
  {
    "David-Kunz/gen.nvim",
    cmd = { "Gen", "GenChat", "GenSelect" },
    opts = {
      model = "mistral", -- default model
      host = "localhost",
      port = "11434",
      display_mode = "float",
      show_prompt = true,
      show_model = true,
      no_auto_close = false,
      init = function(options) end,
      command = function(options)
        return "curl --silent --no-buffer -X POST http://"
          .. options.host
          .. ":"
          .. options.port
          .. "/api/generate -d $body"
      end,
      debug = false,
    },
    keys = {
      { "<leader>ag", ":Gen<cr>", mode = { "n", "v" }, desc = "Generate with AI" },
      { "<leader>ac", ":GenChat<cr>", mode = { "n" }, desc = "AI Chat" },
    },
  },
}
