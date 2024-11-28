return {
  { "mg979/vim-visual-multi" },
  { "ThePrimeagen/git-worktree.nvim" },
  {
    "hat0uma/csvview.nvim",
    config = function()
      require("csvview").setup()
    end,
  },
}
