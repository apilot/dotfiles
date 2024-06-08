source $HOME/.config/nvim/vim-plug/plugins.vim
source $HOME/.config/nvim/plugins-config/airline.vim
source $HOME/.config/nvim/plugins-config/ale.vim
source $HOME/.config/nvim/plugins-config/close-tags.vim
source $HOME/.config/nvim/plugins-config/nerdtree.vim
source $HOME/.config/nvim/plugins-config/rainbow.vim
source $HOME/.config/nvim/general/settings.vim
source $HOME/.config/nvim/general/lsp.vim
source $HOME/.config/nvim/general/themes.vim
source $HOME/.config/nvim/keys/mappings.vim
source $HOME/.config/nvim/keys/which-key.vim
source $HOME/.config/nvim/lua/config.lua

let g:tagbar_ctags_bin = '/usr/bin/ctags'
set mouse=n
" execute pathogen#infect()
syntax on

" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

autocmd VimEnter * NERDTree
" autocmd VimEnter * NvimTreeToggle 

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

