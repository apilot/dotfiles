local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.g.ruby_host_prog = "~/.rbenv/versions/3.3.0/bin/neovim-ruby-host"

require("lazy").setup({ { import = "apilot.plugins" }, { import = "apilot.plugins.lsp" } }, {

	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})
