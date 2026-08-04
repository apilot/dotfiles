return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec" },
  opts = {
    preset = "modern",
    spec = {
      { "<leader>a", group = "AI Assistant" },
      { "<leader>aa", desc = "Open Aider (Qwen3-Coder)", icon = "" },
      { "<leader>am", desc = "Add modified files", icon = "📝" },
      { "<leader>ad", desc = "Add files to Aider", icon = "📁" },
      { "<leader>ag", desc = "Generate with Gen", icon = "🤖" },
      { "<leader>gc", desc = "Gen Chat", icon = "💭" },
      { "<leader>gd", desc = "Diff: MR-style (base...HEAD)", icon = "" },
      { "<leader>gF", desc = "Diff: full (base..HEAD)", icon = "" },
      { "<leader>gD", desc = "Diff: current file history", icon = "📜" },
      { "<leader>gq", desc = "Diff: close", icon = "✕" },
      { "<leader>gn", desc = "Neogit: open", icon = "🪄" },
      { "<leader>gN", desc = "Neogit: current file's repo", icon = "📂" },
      { "<leader>gl", desc = "Neogit: log graph", icon = "📈" },
    },
  },
}
