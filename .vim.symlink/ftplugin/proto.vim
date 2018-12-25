" Enable linter for .proto files
let g:ale_linters = {'proto': ['protoc-gen-lint']}
let b:ale_fixers = {'proto': [
            \   'remove_trailing_lines',
            \]}

