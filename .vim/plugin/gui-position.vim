" Maximize GUI window automatically
function! <SID>SetGuiPos()

    " If there's a .gvimrc-size file use that instead so it can override
    " this setting
    let include = $HOME . "/.vimrc_guisize"

    if filereadable(include)
        " e.g.
        " winpos 0 0
        " set lines=71 columns=155
        exe "source " . include
    elseif has("win32")
        simalt ~x
    elseif has("mac")
        set lines=999 columns=999
    endif

endfunction

augroup SetGuiPos
    autocmd!
    autocmd GUIEnter * exe <SID>SetGuiPos()
augroup END
