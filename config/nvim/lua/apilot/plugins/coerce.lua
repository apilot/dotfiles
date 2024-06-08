return {
	{
		"gregorias/coerce.nvim",
		tag = "v1.0",
		config = function()
			vim.opt.termguicolors = true
			require("bufferline").setup({
				options = {
					mode = "buffers",
					themable = true,
					close_command = "bdelete! %d",
					keymap_prefix = "<leader>gc",
				},
			})
		end,
	},
}
