-- Mermaid diagrams: live browser preview, format, lint, inline render
-- https://github.com/kevalin/mermaid.nvim
-- Requires tree-sitter parser: :TSInstall mermaid (added to 01treesitter.lua)
-- Optional: mmdc (npm i -g @mermaid-js/mermaid-cli) for diagnostics/inline render
return {
  {
    "kevalin/mermaid.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "mermaid" },
    cmd = {
      "MermaidPreview",
      "MermaidPreviewStop",
      "MermaidFormat",
      "MermaidRender",
      "MermaidCopyURL",
    },
    keys = {
      { "<leader>mm", "<cmd>MermaidPreview<CR>", desc = "Mermaid Preview" },
      { "<leader>mf", "<cmd>MermaidFormat<CR>", desc = "Mermaid Format" },
      { "<leader>mr", "<cmd>MermaidRender<CR>", desc = "Mermaid Render" },
      { "<leader>mc", "<cmd>MermaidCopyURL<CR>", desc = "Mermaid Copy URL" },
      { "<leader>mx", "<cmd>MermaidPreviewStop<CR>", desc = "Mermaid Stop Preview" },
    },
    opts = {
      format = {
        shift_width = 2, -- indentation size (spaces)
      },
      lint = {
        -- auto-enable when mmdc is available
        enabled = vim.fn.executable("mmdc") == 1,
        command = "mmdc",
      },
      preview = {
        port = 0, -- 0 = random available port
        renderer = "mermaid.js", -- full spec; "beautiful-mermaid" for aesthetics
        theme = "default", -- dark mode auto-syncs with 'background'
      },
    },
  },
}
