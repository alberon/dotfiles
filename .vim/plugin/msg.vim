" To add [Project Name] to the titlebar:
"   :MSG Project Name
" To clear it again:
"   :MSG
" Based on http://www.vim.org/scripts/script.php?script_id=3033
command! -nargs=? MSG :call SetVimTitle("<args>")

au! BufEnter * call UpdateVimTitleString()
au! BufWinEnter * call UpdateVimTitleString()

function! SetVimTitle(...)
    if a:0 > 0
        let g:vim_session_name = a:1
    else
        unlet g:vim_session_name
    endif
    call UpdateVimTitleString()
endfunction

function! UpdateVimTitleString()
    let &titlestring = ""

    " [Message]
    if exists ("g:vim_session_name") && g:vim_session_name != "" 
        let &titlestring .= "[" . g:vim_session_name . "] "
    endif

    " Filename (Path)
    let &titlestring .= expand("%:t") . " (".expand("%:p:h") . ")"

    " - GVIM1
    if exists ("v:servername") && v:servername != ""
        let &titlestring .= " - " . v:servername
    endif
endfunction

call UpdateVimTitleString()
