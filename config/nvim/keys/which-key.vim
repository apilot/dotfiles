call which_key#register('<Space>', "g:which_key_map", 'n')
call which_key#register('<Space>', "g:which_key_map_visual", 'v')

"telescope find binds
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fc <cmd>Telescope current_buffer_fuzzy_find <cr>
nnoremap <leader>fF :execute 'Telescope find_files default_text=' . expand('<cword>')<cr>
nnoremap <leader>fG :execute 'Telescope live_grep default_text=' . expand('<cword>')<cr>

nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
nnoremap <silent> <leader>gg :LazyGit<CR>
nnoremap <silent> <leader>gb :Gitsigns blame_line<CR>
nnoremap <silent> <leader>gr :Gitsigns reset_hunk<CR>

nnoremap <silent> <Leader>do :lopen<CR>
nnoremap <silent> <Leader>dc :lclose<CR>
nnoremap <silent><leader>q :BufferClose<CR>
let g:which_key_map =  {}

let g:which_key_map['d'] = {
  \ 'name' : '+debug',
  \ 'o' : [':lopen'     , 'Open debug panel'],
  \ 'c' : [':lclose'     , 'Close debug panel'],
\}

let g:which_key_map['q'] = [ ':BufferClose', 'Close buffer' ]

let g:which_key_map['p'] = {
      \ 'name' : '+plug' ,
      \ 'i' : [':PlugInstall'              , 'install'],
      \ 'u' : [':PlugUpdate'               , 'update'],
      \ 'c' : [':PlugClean'                , 'clean'],
      \ 's' : [':source ~/.config/nvim/init.vim', 'source vimrc'],
      \ }

let g:which_key_map['z'] = {
  \ 'name' : '+Follding',
  \ 'o' : ['zo'     , 'Expand'],
  \ 'O' : ['zO'     , 'Expand all'],
  \ 'c' : ['zc'     , 'Collapse'],
\}

let g:which_key_map['g'] = {
  \ 'name' : '+Git',
  \ 'g' : [':LazyGit'     , 'LazyGit'],
  \ 'b' : [':Gitsigns blame_line'     , 'Blame line'],
  \ 'r' : [':Gitsigns reset_hunk'     , 'Reset hunk'],
\}


let g:which_key_map['w'] = {
      \ 'name' : '+windows' ,
      \ 'w' : ['<C-W>w'     , 'other-window']          ,
      \ 'd' : ['<C-W>c'     , 'delete-window']         ,
      \ '-' : ['<C-W>s'     , 'split-window-below']    ,
      \ '|' : ['<C-W>v'     , 'split-window-right']    ,
      \ '2' : ['<C-W>v'     , 'layout-double-columns'] ,
      \ 'h' : ['<C-W>h'     , 'window-left']           ,
      \ 'j' : ['<C-W>j'     , 'window-below']          ,
      \ 'l' : ['<C-W>l'     , 'window-right']          ,
      \ 'k' : ['<C-W>k'     , 'window-up']             ,
      \ 'f' : [':tabedit %' , 'Fullscreen']            ,
      \ 'm' : [':tabclose'  , 'Split view']            ,
      \ 'H' : ['<C-W>5<'    , 'expand-window-left']    ,
      \ 'J' : [':resize +5' , 'expand-window-below']   ,
      \ 'L' : ['<C-W>5>'    , 'expand-window-right']   ,
      \ 'K' : [':resize -5' , 'expand-window-up']      ,
      \ '=' : ['<C-W>='     , 'balance-window']        ,
      \ 's' : ['<C-W>s'     , 'split-window-below']    ,
      \ 'v' : ['<C-W>v'     , 'split-window-below']    ,
      \ }

let g:which_key_map.l = {
      \ 'name' : '+lsp',
      \ 'f' : ['spacevim#lang#util#Format()'          , 'formatting']       ,
      \ 'r' : ['spacevim#lang#util#FindReferences()'  , 'references']       ,
      \ 'R' : ['spacevim#lang#util#Rename()'          , 'rename']           ,
      \ 's' : ['spacevim#lang#util#DocumentSymbol()'  , 'document-symbol']  ,
      \ 'S' : ['spacevim#lang#util#WorkspaceSymbol()' , 'workspace-symbol'] ,
      \ 'g' : {
        \ 'name': '+goto',
        \ 'd' : ['spacevim#lang#util#Definition()'     , 'definition']      ,
        \ 't' : ['spacevim#lang#util#TypeDefinition()' , 'type-definition'] ,
        \ 'i' : ['spacevim#lang#util#Implementation()' , 'implementation']  ,
        \ },
      \ }
let g:which_key_map['r'] = {
  \ 'name' : '+rspec',
  \ 'r' : [':Neotest run file', 'Run Nearest test in file']        ,
  \ 'l' : [':Neotest run last', 'Run Last test']                   ,
  \ 'a' : [':Neotest attach', 'Attach Nearest test']               ,
  \ 'o' : [':Neotest output', 'Neotest output']                    ,
  \ 's' : [':Neotest summary toggle', 'Neotest summary']           ,
  \ 'S' : [':Neotest stop', 'Neotest stop']                        ,
  \ 'p' : [':Neotest output-panel toggle', 'Output panel toggle']  ,
    \ 'j' : {
  \ 'name' : '+jump',
  \ 'n' : [':Neotest jump next', 'Jump next']                      ,
  \ 'p' : [':Neotest jump prev', 'Jump prev']                      ,
  \},
\}
let g:which_key_map['f'] = {
  \ 'name' : '+telescope',
  \ 'f' : [':Telescope find_files '     , 'Find files'],
  \ 'F' : [':Telescope find_files default_text=' + expand("<cword>")     , 'Find files under cursor'],
  \ 'g' : [':Telescope live_grep'     , 'Global text search'],
  \ 'G' : [':Telescope grep_string'     , 'Global text search under cursor'],
  \ 'b' : [':Telescope buffers'     , 'Buffers list'],
  \ 'h' : [':Telescope help_tags'     , 'Find help tags'],
  \ 'c' : [':Telescope current_buffer_fuzzy_find'     , 'Buffer text search'],
  \ 't' : [':Telescope git_worktree git_worktrees', 'List worktrees'],
  \ 'T' : [':Telescope git_worktree create_git_worktree', 'Create worktree'],
  \ 'B' : [':Telescope file_browser', 'File browser'],
\}
