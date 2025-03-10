return {
  { "mg979/vim-visual-multi" },
  { "equalsraf/neovim-gui-shim" },
  { "ThePrimeagen/git-worktree.nvim" },
  {
    "hat0uma/csvview.nvim",
    config = function()
      require("csvview").setup()
    end,
  },
  {
    "theRealCarneiro/hyprland-vim-syntax",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = "hypr",
  },
}
