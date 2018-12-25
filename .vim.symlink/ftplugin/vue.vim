let g:vim_vue_plugin_use_scss = 1

let b:ale_fixers = {'vue': [
            \   'prettier',
            \]}

" Run both javascript and vue linters for vue files.
let b:ale_linter_aliases = ['javascript', 'vue']
" Select the eslint and vls linters.
let b:ale_linters = ['eslint', 'vls']

