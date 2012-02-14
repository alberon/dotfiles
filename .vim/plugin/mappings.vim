" Use ; instead of : for commands (don't need to press shift so much)
nnoremap ; :
vnoremap ; :

" Ctrl+direction to switch buffers
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Cycle through buffers
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

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

" Make increment/decrement work in Windows using alt
noremap <M-a> <C-a>
noremap <M-x> <C-x>

" Make spacebar run macro @q (so it can be quickly recorded with 'qq' and then
" run repeatedly with <Space>)
nnoremap <Space> @q

"===============================================================================
" Leader mappings
"===============================================================================

" Use , as the leader for my own keyboard shortcuts
let mapleader = ","

" Alternate files (a.vim)
nmap <Leader>a :AT<CR>

" Buffers (list and open prompt ready to switch)
"nmap <Leader>b :buffers<CR>:buffer 
" Buffers (FuzzyFinder)
nmap <Leader>b :FufBuffer<CR>

" NERD Commenter = <Leader>c* (e.g. c, n, u)

" DirDiff = <Leader>d* (k, j, p, g)

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

    if line != ""
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

" Insert Date (DDD D MMM YYYY)
nmap <silent> <Leader>id a<C-R>=strftime("%a %#d %b %Y")<CR>

" Toggle line numbers
nmap <silent> <Leader>n :set number!<CR>

" Open file
nmap <silent> <Leader>of :FufFile<CR>

" Open snippets directory
nmap <silent> <Leader>os :tabedit $HOME/.vim/snippets<CR>

" Open .vimrc
nmap <silent> <Leader>ov :tabedit $HOME/.vimrc<CR>

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
nmap <silent> <Leader>1t :setlocal tabstop=1 softtabstop=1 shiftwidth=1<CR>
nmap <silent> <Leader>2t :setlocal tabstop=2 softtabstop=2 shiftwidth=2<CR>
nmap <silent> <Leader>3t :setlocal tabstop=3 softtabstop=3 shiftwidth=3<CR>
nmap <silent> <Leader>4t :setlocal tabstop=4 softtabstop=4 shiftwidth=4<CR>
nmap <silent> <Leader>5t :setlocal tabstop=5 softtabstop=5 shiftwidth=5<CR>
nmap <silent> <Leader>6t :setlocal tabstop=6 softtabstop=6 shiftwidth=6<CR>
nmap <silent> <Leader>7t :setlocal tabstop=7 softtabstop=7 shiftwidth=7<CR>
nmap <silent> <Leader>8t :setlocal tabstop=8 softtabstop=8 shiftwidth=8<CR>

" Switch to using tabs instead of spaces to indent (or back again)
nmap <silent> <Leader>t :setlocal noexpandtab<CR>
nmap <silent> <Leader>T :setlocal expandtab<CR>

" Write
nmap <silent> <Leader>w :w<CR>

" Graphical undo
nmap <silent> <Leader>z :GundoToggle<CR>
