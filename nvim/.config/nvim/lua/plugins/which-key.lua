return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec" },
  opts = {
    preset = "modern",
    spec = {
      { "<leader>a", group = "AI Assistant" },
      { "<leader>aa", desc = "Open Aider (Qwen3-Coder)", icon = "" },
      { "<leader>am", desc = "Add modified files", icon = "📝" },
      { "<leader>ad", desc = "Add files to Aider", icon = "📁" },
      { "<leader>ag", desc = "Generate with Gen", icon = "🤖" },
      { "<leader>gc", desc = "Gen Chat", icon = "💭" },
    },
  },
}
