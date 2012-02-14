" Remember cursor position for each file
" http://vim.sourceforge.net/tips/tip.php?tip_id=80
autocmd BufReadPost *
\   if expand("<afile>:p:h") !=? $TEMP |
\       if line("'\"") > 1 && line("'\"") <= line("$") |
\           let JumpCursorOnEdit_foo = line("'\"") |
\           let b:doopenfold = 1 |
\           if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
\               let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
\               let b:doopenfold = 2 |
\           endif |
\           exe JumpCursorOnEdit_foo |
\       endif |
\   endif

" Need to postpone using "zv" until after reading the modelines.
autocmd BufWinEnter *
\   if exists("b:doopenfold") |
"\       exe "normal zv" |
\       if (b:doopenfold > 1) |
\           exe  "+".1 |
\       endif |
\       unlet b:doopenfold |
\   endif
