syntax on
set clipboard+=unnamedplus
let g:mapleader=' '

let g:python3_host_prog = '/usr/bin/python'
set expandtab
set tabstop=2 
set incsearch
set hlsearch
set cursorline
set cursorcolumn
highlight CursorLine ctermbg=235 guibg=#28303d
highlight CursorColumn ctermbg=122 guibg=#28303d
set nu "Отображать номеe астрок
set sw=2 "Заменяет TAB на 2 пробела
set sts=2 "Аналогично, но в случае автоотступа
let g:fuzzy_ignore = "gems/*"
let g:deoplete#enable_at_startup = 1
autocmd Filetype * AnyFoldActivate
autocmd TermClose * :echo expand('<abuf>')
autocmd FileType TelescopePrompt call deoplete#custom#buffer_option('auto_complete', v:false)
let g:anyfold_fold_comments=1
set foldlevel=0

" (Optional) Enable terraform plan to be include in filter
let g:syntastic_terraform_tffilter_plan = 1

" (Optional) Default: 0, enable(1)/disable(0) plugin's keymapping
let g:terraform_completion_keys = 1

" (Optional) Default: 1, enable(1)/disable(0) terraform module registry completion
let g:terraform_registry_module_completion = 0

" tab options
let g:barbar_auto_setup = v:false
" Syntastic Config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" (Optional)Remove Info(Preview) window
set completeopt-=preview

" (Optional)Hide Info(Preview) window after completions
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif
