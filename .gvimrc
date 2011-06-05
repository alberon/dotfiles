" No toolbar - I never use it!
set guioptions-=T

" Deactivate cursor blinking
"set guicursor=a:blinkon0

" <Ctrl-S> shows save dialog for new files
map <silent> <C-s> :if expand("%") == ""<CR>:browse confirm w<CR>:else<CR>:confirm w<CR>:endif<CR>
inoremap <silent> <C-s> <C-o>:if expand("%") == ""<CR>:browse confirm w<CR>:else<CR>:confirm w<CR>:endif<CR>
vnoremap <silent> <C-s> <C-c>:if expand("%") == ""<CR>:browse confirm w<CR>:else<CR>:confirm w<CR>:endif<CR>

" <Ctrl-O> shows open dialog
inoremap <silent> <C-o> <C-o>:browse e<CR>

" <Ctrl-F> shows find dialog
inoremap <silent> <C-f> <C-o>:promptfind<CR>

"================================================================================
" Maximize window automatically
"================================================================================
function! SetGuiPos()
    
    if has("win32")
        let include = $VIM . "/.gvimrc_size"
    else
        let include = $HOME . "/.gvimrc_size"
    endif
    
    if filereadable(include)
        exe "source " . include
        " e.g.
        " winpos 0 0
        " set lines=71 columns=155
    elseif has("win32")
        simalt ~x
    endif
    
endfunction

autocmd GUIEnter * exe SetGuiPos()

"================================================================================
" Titlebar and tab titles
"================================================================================
" Always show tabs
set showtabline=2

" Tab shortcuts
map <C-t> :tabnew<cr>
nmap <C-t> :tabnew<cr>
imap <C-t> <ESC>:tabnew<cr>

" Set titlebar to full path to current file
" Except when it's opened from WinSCP strip the temp directory prefix off
function GetTabFilename()
    let filename = expand("%:p")
    let title = 'gVim'
    if filename != "" && match(filename, 'NERD_tree_[0-9]\+$') == -1
        let filename = substitute(filename, '^.*\\temp\\scp[0-9]\+\\', '', 'i')
        let title .= ' - ' . filename
    endif
    return title
endfunction

autocmd BufEnter * let &titlestring = GetTabFilename()

" Set up tab labels with tab number, buffer name, number of windows
function! GuiTabLabel()
    let label = ''
    let bufnrlist = tabpagebuflist(v:lnum)
    
    " Tab number
    let label .= v:lnum.': '
    
    " Buffer name
    let name = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
    if name != ''
        let name = fnamemodify(name,":t")
    elseif &buftype == 'quickfix'
        let name = '[Quickfix List]'
    else
        let name = '[No Name]'
    endif
    let label .= name
    
    " Append the number of windows in the tab page
    let wincount = tabpagewinnr(v:lnum, '$')
    if wincount > 1
        let label .= ' [' . wincount . ']'
    endif
    
    " Add '+' if one of the buffers in the tab page is modified
    for bufnr in bufnrlist
        if getbufvar(bufnr, "&modified")
            let label .= '+'
            break
        endif
    endfor
    
    return label
endfunction
set guitablabel=%{GuiTabLabel()}

"================================================================================
" Diff Patch
"================================================================================
if has("diff")
    
    func! <SID>diffmakepatch()
    
        if expand("%") == ""
            
            " Unsaved - Error
            echo "Please save first!"
            
        else
            
            " TODO: Warn before overwriting existing file OR create in a new buffer
            
            " Get file
            let filename = browse(0, "Create Patch To File...", expand("%:p:h"), "")
            if filename == ""
                return
            endif
            
            " Run diff
            let opt = ""
            if &diffopt =~ "icase"
                let opt = opt . "-i "
            endif
            if &diffopt =~ "iwhite"
                let opt = opt . "-b "
            endif
            if has("win32")
                silent execute '!="'.$VIMRUNTIME.'\diff.exe" -c '.opt.'"'.expand("%").'" "'.filename.'" > "'.expand("%").'.diff"'
            else
                silent execute '!diff -c '.opt.'"'.expand("%").'" "'.filename.'" > "'.expand("%").'.diff"'
            endif
            
            " Edit file
            silent execute "vsplit " . expand("%") . ".diff"
            
        endif
        
    endfunc
    
    an 10.430 &File.Split\ C&reate\ Patch\.\.\. :call <SID>diffmakepatch()<CR>
    
endif

"================================================================================
" Open URL
"================================================================================
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
map <silent> <Leader>w :call Browser ()<CR>
