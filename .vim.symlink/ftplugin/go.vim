let g:ale_linters = {'go': ['gofmt']}
let b:ale_fixers = {'go': [
            \   'remove_trailing_lines',
            \   'gofmt',
            \   'goimports',
            \]}
