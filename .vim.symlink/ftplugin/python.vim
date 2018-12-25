
" pep8 for python file
"au BufNewFile,BufRead *.py
"    \ set tabstop=4
"    \ set softtabstop=4
"    \ set shiftwidth=4
"    \ set textwidth=79
"    \ set expandtab
"    \ set autoindent
"    \ set fileformat=unix
"

" let g:formatters_python = ['yapf']



let b:ale_linters = ['flake8', 'black']
let b:ale_fixers = {'python': [
            \   'remove_trailing_lines',
            \   'isort',
            \   'black',
            \]}
