" Make ^Z undo smaller chunks at a time
" http://vim.wikia.com/wiki/Modified_undo_behavior
inoremap <BS> <C-g>u<BS>
inoremap <Del> <C-g>u<Del>
inoremap <C-W> <C-g>u<C-W>

" Make paste an undoable action, rather than joining it with any text that's typed in
" Also use character-wise instead of line-wise paste, so it goes where the
" cursor is instead of on the line above
if exists("*paste#Paste")

    function! <SID>MyPaste()

        " Set to character-wise
        " http://vim.wikia.com/wiki/Unconditional_linewise_or_characterwise_paste
        let reg_type = getregtype("+")
        call setreg("+", getreg("+"), "v")

        " Use the bundled paste command
        call paste#Paste()

        " Reset line/character-wise
        call setreg("+", getreg("+"), reg_type)

    endfunction

    " Explanation:
    " <C-g>u                      Set undo point
    " <C-o>:call MyPaste()<CR>    Call the function above
    " <C-g>u                      Set another undo point
    " 2010-06-19 Removed the final undo point because it seems to cause problems
    "            when ThinkingRock is open...
    "inoremap <C-V> <C-g>u<C-o>:call MyPaste()<CR><C-g>u
    inoremap <C-V> <C-g>u<C-o>:call <SID>MyPaste()<CR>

endif
