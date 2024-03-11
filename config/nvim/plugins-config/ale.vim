let g:ale_linters = {
      \   'ruby': ['standardrb', 'rubocop'],
      \   'python': ['flake8', 'pylint'],
      \   'javascript': ['eslint'],
      \   'html': ['prettier'],
      \   'eruby': ['standardrb'],
      \}

let g:ale_fixers = {
      \    'ruby': ['standardrb', 'solargraph'],
      \    'javascript': ['prettier', 'eslint'],
      \    'html': ['prettier'],
      \    'eruby': ['erb-formatter'],
      \}
let g:ale_fix_on_save = 1
