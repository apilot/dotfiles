let g:ale_linters = {
      \   'ruby': ['standardrb', 'rubocop'],
      \   'python': ['flake8', 'pylint'],
      \   'javascript': ['eslint'],
      \   'eruby': ['standardrb'],
      \   'yaml': ['yaml-language-server'],
      \}

let g:ale_fixers = {
      \    '*': ['remove_trailing_lines', 'trim_whitespace'],
      \    'ruby': ['standardrb'],
      \    'javascript': ['prettier', 'eslint'],
      \    'yaml': ['yamlfmt'],
      \    'html-beautify': ['html-beautify'],
      \    'eruby': ['erb-formatter'],
      \}
let g:ale_fix_on_save = 1
