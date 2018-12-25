Sylvain's dotfiles.

## VIM bindings and cheat sheet

|Reopen a buffer|:e or :edit!|
|Toggle case|~ g~|
|Upper case|gU gUw gUiw|
|Lower case|gu guw guiw|
|Close preview|:pc[lose] or <c-w>z|
|Toggle comment|gcc gc and a movement|
|Center cursor|zz|
|Delete a paragraph|dap|

|Stop search highlight|<esc><esc>|
|fzf in buffers|;|
|fzf in files|<leader>t|

Navigation:
|Switch between buffers, |gb GB|
|List buffers|<leader>b <leader>B|
|Next git hunk|]c|
|Prev git hunk|[c|
|Go to line|42G 42gg :42|
|Mark like|ma mA mb|
|Next lint error|]r|
|Previous lint erro|[r|

Splits:
|Create an horizontal split|:sp|
|Create a vertical split|:vsp|
|Maximize a split|ctrl+w \| or \_|
|Normalize splits sizes|ctrl+w =|

Diff:
|Diff between two splits|:windo diffthis|
|Stop diff view|:windo diffoff|
|Next diff|]c|
|Prev diff|[c|

Git related actions:
|Hunks: preview|<leader>hp|
|Hunks: stage|<leader>hs|
|Hunks: undo|<leader>hu|
|Next hunk|]c|
|Previous hunk|[c|

IDE
|Autoindent|<leader>=|

Misc:
|Reload .vimrc|:so $MYVIMRC|

## Misc

Thanks to:
- Mathias Bynens: https://github.com/mathiasbynens/dotfiles
- Zach Holman: https://github.com/holman/dotfiles
- http://hints.macworld.com/article.php?story=20131123074223584
- https://github.com/samoshkin/tmux-config
