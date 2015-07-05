" Use ; instead of : for commands (don't need to press shift so much)
nnoremap ; :
vnoremap ; :

" Ctrl+tab to switch windows
nnoremap <C-Tab> <C-w>w
nnoremap <C-S-Tab> <C-w>p

" Ctrl+direction to switch windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Cycle through buffers
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

" Switch buffer quickly by pressing spacebar
" Note: :b supports tab-completion, and it's much faster than BufExplorer or
" any or the other plugins I've tried
"nmap <Space> :b 
" ... Going to try Ctrl-P for a while - but only for buffers because the file
" search takes ages to load
nmap <Space> :CtrlPBuffer<CR>

" Ctrl-Space for Buffer Explorer - slower, but easier for browsing the list of
" open buffers if I can't remember the filename
nmap <silent> <C-Space> :call MyBufExplorer()<CR>

" Navigate by screen lines rather than file lines
nnoremap k gk
nnoremap j gj
nnoremap <Up> gk
inoremap <Up> <C-O>gk
vnoremap <Up> gk
nnoremap <Down> gj
inoremap <Down> <C-O>gj
vnoremap <Down> gj
nnoremap <Home> g0
inoremap <Home> <C-O>g0
nnoremap <End> g$
inoremap <End> <C-O>g$

" gf = Goto file under cursor (even if it doesn't exist yet)
nmap gf :e <cfile><CR>

" Use visual mode for Ctrl-A (select all)
noremap <C-A> ggvG$
inoremap <C-A> <C-O>gg<C-O>vG$
cnoremap <C-A> <C-C>ggvG$
onoremap <C-A> <C-C>ggvG$
if v:version >= 700
    snoremap <C-A> <C-C>ggvG$
    xnoremap <C-A> <C-C>ggvG$
endif

" Keep selection when indenting block-wise
if version >= 700
    xnoremap < <gv
    xnoremap > >gv
endif

" Swap two text blocks by deleting the first block then visually selecting the
" second block and pressing x (mneumonic: eXchange)
vnoremap x <Esc>`.``gvP``P

" Make increment/decrement work in Windows using alt
noremap <M-a> <C-a>
noremap <M-x> <C-x>

" Make F5 run macro @q (so it can be quickly recorded with 'qq' and then
" run repeatedly with <F5>)
nnoremap <F5> @q
vnoremap <F5> @q

"===============================================================================
" Leader mappings
"===============================================================================

" Use , as the leader for my own keyboard shortcuts
let mapleader = ","

" Alternate files (a.vim)
nmap <Leader>a :A<CR>

" NERD Commenter = <Leader>c* (e.g. c, n, u)

" BufExplorer
nmap <silent> <Leader>b :call MyBufExplorer()<CR>

" Delete spaces from otherwise empty lines
nmap <silent> <Leader>ds :call PreserveCursor('%s/^\s\+$//e')<CR>

" Delete trailing spaces
nmap <silent> <Leader>dt :call PreserveCursor('%s/\s\+$//e')<CR>

" Browse current directory
nmap <silent> <Leader>e :edit %:p:h<CR>
nmap <silent> <Leader>E :tabedit %:p:h<CR>

" Open URL in Firefox
" http://vim.wikia.com/wiki/Open_a_web-browser_with_the_URL_in_the_current_line
if has("win32")
    let $PATH .= ';c:\Program Files (x86)\Mozilla Firefox;c:\Program Files\Mozilla Firefox'
endif

function! <SID>Browser()

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

    if line == ""
        echo "No URL found"
    else
        if has("win32")
            exec ':silent !start firefox.exe "' . line . '"'
        else
            exec ':silent !firefox "' . line . '"'
        endif
    endif

endfunction

nmap <silent> <Leader>ff :call <SID>Browser()<CR>

" Toggle search highlight
nmap <silent> <Leader>h :set hlsearch!<CR>

" Remove DOS line endings
" I would just use ,m - but the Align plugin using ,m= which slows it down
nmap <silent> <Leader>mm :call PreserveCursor('%s/\r$//')<CR>

" Find current file in NERDtree
nmap <silent> <Leader>n :NERDTreeFind<CR>

" Toggle line numbers
nmap <silent> <Leader>N :set number!<CR>

" Open snippets directory
nmap <silent> <Leader>os :edit $HOME/.vim/snippets<CR>

" Open Vim settings
nmap <silent> <Leader>ov :edit $HOME/.vim<CR>

" Toggle paste mode
nmap <silent> <Leader>p :set paste!<CR>

" Quit
nmap <silent> <Leader>q :q<CR>
nmap <silent> <Leader>Q :wq<CR>

" Split screen in various directions
nmap <silent> <Leader>ss         :split<CR>
nmap <silent> <Leader>sv         :vsplit<CR>
nmap <silent> <Leader>sh         :leftabove  :vsplit<CR>
nmap <silent> <Leader>sj         :belowright :split<CR>
nmap <silent> <Leader>sk         :aboveleft  :split<CR>
nmap <silent> <Leader>sl         :rightbelow :vsplit<CR>
nmap <silent> <Leader>s<Left>    :leftabove  :vsplit<CR>
nmap <silent> <Leader>s<Down>    :belowright :split<CR>
nmap <silent> <Leader>s<Up>      :aboveleft  :split<CR>
nmap <silent> <Leader>s<Right>   :rightbelow :vsplit<CR>

" Change the tab size
nmap <Leader>0t :set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab listchars-=tab:-\   listchars+=tab:\ \ <CR>
nmap <Leader>1t :set tabstop=1 softtabstop=1 shiftwidth=1 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>2t :set tabstop=2 softtabstop=2 shiftwidth=2 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>3t :set tabstop=3 softtabstop=3 shiftwidth=3 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>4t :set tabstop=4 softtabstop=4 shiftwidth=4 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>5t :set tabstop=5 softtabstop=5 shiftwidth=5 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>6t :set tabstop=6 softtabstop=6 shiftwidth=6 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>7t :set tabstop=7 softtabstop=7 shiftwidth=7 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>8t :set tabstop=8 softtabstop=8 shiftwidth=8 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>

nmap <Leader>0T :setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab listchars-=tab:-\   listchars-=tab:-\ <CR>
nmap <Leader>1T :setlocal tabstop=1 softtabstop=1 shiftwidth=1 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>2T :setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>3T :setlocal tabstop=3 softtabstop=3 shiftwidth=3 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>4T :setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>5T :setlocal tabstop=5 softtabstop=5 shiftwidth=5 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>6T :setlocal tabstop=6 softtabstop=6 shiftwidth=6 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>7T :setlocal tabstop=7 softtabstop=7 shiftwidth=7 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap <Leader>8T :setlocal tabstop=8 softtabstop=8 shiftwidth=8 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>

" Write
nmap <silent> <Leader>w :w<CR>

" Explorer (current file directory, or current working directory)
nmap <silent> <Leader>x :silent !start explorer %:p:h<CR>
nmap <silent> <Leader>X :silent !start explorer .<CR>

" Graphical undo
nmap <silent> <Leader>z :GundoToggle<CR>

" HTML tags
function! <SID>VisualWrap(before, after, ...)
    let tmp = @k
    " Copy to register
    normal gv"ky
    " Modify register
    let @k = a:before . @k . a:after
    " Paste from register
    normal gv"kp
    " Revert register contents
    let @k = tmp
    " Position cursor
    if a:0 > 0 && a:1 > 0
        normal `<
        exe "normal " . a:1 . "l"
    endif
endfunction

vmap <silent> <Leader><C-b> <Esc>:call <SID>VisualWrap("<strong>", "</strong>")<CR>
vmap <silent> <Leader><C-d> <Esc>:call <SID>VisualWrap("<div>", "</div>", 4)<CR>
vmap <silent> <Leader><C-i> <Esc>:call <SID>VisualWrap("<em>", "</em>")<CR>
vmap <silent> <Leader><C-k> <Esc>:call <SID>VisualWrap("<a href=\"\">", "</a>", 9)<CR>
vmap <silent> <Leader><C-p> <Esc>:call <SID>VisualWrap("<p>", "</p>")<CR>
vmap <silent> <Leader><C-s> <Esc>:call <SID>VisualWrap("<span>", "</span>", 5)<CR>
vmap <silent> <Leader><C-u> <Esc>:call <SID>VisualWrap("<u>", "</u>")<CR>
