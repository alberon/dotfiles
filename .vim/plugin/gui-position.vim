" Maximize GUI window automatically
function! <SID>SetGuiPos()

    " If there's a .gvimrc-size file use that instead so it can override
    " this setting
    let include = $HOME . "/.vim/.gvimrc-size"

    if filereadable(include)
        " e.g.
        " winpos 0 0
        " set lines=71 columns=155
        exe "source " . include
    elseif has("win32")
        simalt ~x
    endif

endfunction

augroup SetGuiPos
    autocmd!
    autocmd GUIEnter * exe <SID>SetGuiPos()
augroup END
