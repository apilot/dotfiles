call plug#begin('~/.config/nvim/plugged')
  if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
  endif
  Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }
  Plug 'Keithbsmiley/rspec.vim', { 'for': 'ruby' }
  Plug 'Shougo/neco-syntax'
  Plug 'Shougo/neosnippet-snippets'
  Plug 'Shougo/neosnippet.vim'
  Plug 'SirVer/ultisnips'
  Plug 'lukas-reineke/indent-blankline.nvim'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'vim-scripts/VimCompletesMe'
  Plug 'alvan/vim-closetag'
  Plug 'ap/vim-css-color'
  Plug 'bfredl/nvim-miniyank'
  Plug 'cespare/vim-toml'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'dense-analysis/ale'
  Plug 'dzeban/vim-log-syntax'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'ekalinin/dockerfile.vim'
  Plug 'etordera/deoplete-rails'
  Plug 'fisadev/FixedTaskList.vim'      " Pending tasks list
  Plug 'freeo/vim-kalisi'
  Plug 'hashivim/vim-terraform'
  Plug 'honza/vim-snippets'
  Plug 'int3/vim-extradite'
  Plug 'jgdavey/vim-blockle'
  Plug 'jiangmiao/auto-pairs'
  Plug 'juliosueiras/vim-terraform-completion'
  Plug 'kana/vim-textobj-user', { 'for': ['ruby'] }
  Plug 'kchmck/vim-coffee-script'
  Plug 'kchmck/vim-coffee-script', { 'for': ['coffee', 'haml', 'eruby'] }
  Plug 'majutsushi/tagbar'              " Class/module browser
  Plug 'mfussenegger/nvim-lint'
  Plug 'morhetz/gruvbox'
  Plug 'lifepillar/vim-gruvbox8'
  Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
  Plug 'sainnhe/sonokai'
  Plug 'mustache/vim-mustache-handlebars'
  Plug 'mxw/vim-jsx', { 'for': 'javascript.jsx' }
  Plug 'nelstrom/vim-textobj-rubyblock', { 'for': ['ruby'] }
  Plug 'othree/eregex.vim'
  Plug 'othree/html5.vim'
  Plug 'othree/javascript-libraries-syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }
  Plug 'othree/jspc.vim', { 'for': ['javascript', 'javascript.jsx'] }
  Plug 'pseewald/vim-anyfold'
  Plug 'rhysd/vim-grammarous'
  Plug 'rking/ag.vim'
  Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle' }            " Project and file navigation
  Plug 'Xuyuanp/nerdtree-git-plugin'
  Plug 'slim-template/vim-slim'
  Plug 'stephpy/vim-yaml'
  Plug 'thinca/vim-localrc'
  Plug 'antoinemadec/FixCursorHold.nvim'
  Plug 'nvim-neotest/neotest'
  Plug 'olimorris/neotest-rspec'
  Plug 'tpope/vim-commentary'
  Plug 'nvim-treesitter/nvim-treesitter'
  Plug 'tpope/vim-endwise'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rails'
  Plug 'tpope/vim-surround'
  Plug 'kdheepak/lazygit.nvim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'vim-ruby/vim-ruby'
  Plug 'vim-syntastic/syntastic'
  Plug 'xolox/vim-misc'
  Plug 'xolox/vim-notes'
  Plug 'declancm/cinnamon.nvim'
  " tabs for vim
  Plug 'romgrk/barbar.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'https://github.com/ryanoasis/vim-devicons'
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.4' }
  Plug 'liuchengxu/vim-which-key'
  Plug 'luochen1990/rainbow'
  Plug 'codota/tabnine-nvim', { 'do': './dl_binaries.sh' }
  Plug 'mg979/vim-visual-multi', {'branch': 'master'}
  set encoding=UTF-8
call plug#end()
