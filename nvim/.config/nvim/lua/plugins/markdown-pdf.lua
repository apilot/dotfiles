-- Markdown to PDF conversion and preview
-- https://github.com/arminveres/md-pdf.nvim
return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts_extend = { "spec" },
    opts = {
      spec = {
        { "<leader>m", group = "Markdown" },
      },
    },
  },
  {
    "arminveres/md-pdf.nvim",
    branch = "main",
    lazy = true,
    keys = {
      {
        "<leader>mp",
        function()
          require("md-pdf").convert_md_to_pdf()
        end,
        ft = "markdown",
        desc = "Markdown to PDF",
      },
    },
    ---@type md-pdf.config
    opts = {
      margins = "20mm",
      highlight = "tango",
      toc = true,
      pdf_engine = "weasyprint",
      ignore_viewer_state = false,
      preview_cmd = function()
        return "xdg-open"
      end,
    },
  },
}
