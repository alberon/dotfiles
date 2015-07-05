let g:bufExplorerDefaultHelp = 0
let g:bufExplorerShowRelativePath = 1
"let g:bufExplorerSortBy = 'fullpath'
let g:bufExplorerSplitOutPathName = 0

function! MyBufExplorer()

    " Record which buffer we're currently on
    let current_buffer = bufnr("%")

    " Do nothing if we're already in Buffer Explorer - otherwise it redraws
    " with the wrong buffer highlighted
    if bufname(current_buffer) == "[BufExplorer]"
        return
    endif

    " Load Buffer Explorer
    execute ":BufExplorer"

    " If we're now in a different buffer...
    if bufnr("%") != current_buffer
        " Keep a record of the current search
        let _s=@/
        " Jump to the buffer number that we were on before
        silent! execute "/^\\s*" . current_buffer . "\\s\\+"
        " Jump to the third column (the filename)
        normal 2W
        " Reset the search
        let @/=_s
    endif

endfunction
