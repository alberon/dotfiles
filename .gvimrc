" No toolbar - I never use it!
set guioptions-=T

" <Ctrl-S> shows save dialog for new files
map <silent> <C-s> :if expand("%") == ""<CR>:browse confirm w<CR>:else<CR>:confirm w<CR>:endif<CR>
inoremap <silent> <C-s> <C-o>:if expand("%") == ""<CR>:browse confirm w<CR>:else<CR>:confirm w<CR>:endif<CR>
vnoremap <silent> <C-s> <C-c>:if expand("%") == ""<CR>:browse confirm w<CR>:else<CR>:confirm w<CR>:endif<CR>

" <Ctrl-O> shows open dialog
inoremap <silent> <C-o> <C-o>:browse e<CR>

" <Ctrl-F> shows find dialog
inoremap <silent> <C-f> <C-o>:promptfind<CR>

" Maximize window automatically
function! SetGuiPos()

    " If there's a .gvimrc_size file use that instead so it can override
    " this setting
    if has("win32")
        let include = $VIM . "/.gvimrc_size"
    else
        let include = $HOME . "/.gvimrc_size"
    endif

    if filereadable(include)
        " e.g.
        " winpos 0 0
        " set lines=71 columns=155
        exe "source " . include
    elseif has("win32")
        simalt ~x
    endif

endfunction

autocmd GUIEnter * exe SetGuiPos()

" Open URL in Firefox
" http://vim.wikia.com/wiki/Open_a_web-browser_with_the_URL_in_the_current_line
let $PATH = $PATH . ';c:\Program Files (x86)\Mozilla Firefox;c:\Program Files\Mozilla Firefox'
function! Browser()

    let line0 = getline(".")

    let line = matchstr(line0, "http[^ ]*")
    if line == ""
        let line = matchstr(line0, "ftp[^ ]*")
    endif
    if line == ""
        let line = matchstr(line0, "file[^ ]*")
    endif
    "let line = escape(line, "#?&;|%")
    let line = escape(line, "#")

    " This opens the current file in Firefox by default
    "if line == ""
    "  let line = "\"" . (expand("%:p")) . "\""
    "endif

    if line != ""
        exec ':silent !start firefox.exe "' . line . '"'
    endif

endfunction
map <silent> <Leader>ff :call Browser()<CR>
