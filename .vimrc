scriptencoding utf-8

" Debugging
"set verbose=9

" Make sure any autocommands are replaced not added to when reloading this file
augroup vimrc
autocmd!


"===============================================================================
" Plugins
"===============================================================================

" Automatically install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !echo "Downloading vim-plug..."; curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Automatically install missing plugins
autocmd VimEnter *
\   if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
\|      PlugInstall --sync
\|      quit
\|      source $MYVIMRC
\|  endif

" Configure plugins
call plug#begin('~/.vim/plugged')
    Plug 'ap/vim-css-color'
    Plug 'bogado/file-line'
    Plug 'chrisbra/csv.vim'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'garbas/vim-snipmate'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'itchyny/lightline.vim'
    Plug 'MarcWeber/vim-addon-mw-utils' " Dependency of SnipMate
    Plug 'posva/vim-vue'
    Plug 'pprovost/vim-ps1'
    Plug 'preservim/nerdcommenter'
    Plug 'tomtom/tlib_vim' " Dependency of SnipMate
    Plug 'tpope/vim-eunuch' " :Rename, :Delete, :SudoWrite, etc.
call plug#end()

" Core plugins
if version >= 800
    packadd matchit " Make % jump between XML tags as well as normal brackets
else
    runtime macros/matchit.vim
endif


"===============================================================================
" Settings
"===============================================================================

if !isdirectory($HOME . '/.cache/vim')
    call mkdir($HOME . '/.cache/vim', 'p', 0700)
endif

"---------------------------------------
" Core settings
"---------------------------------------

runtime mswin.vim

set autoindent
set autoread
set backupcopy=yes
set backupdir=~/.cache/vim//
set colorcolumn=81,121
set confirm
set cryptmethod=blowfish2
set directory=~/.cache/vim//
set expandtab
set fileencodings=ucs-bom,utf-8,default,latin1
set fillchars=vert:\|,fold:\ 
set foldmethod=marker
set formatoptions+=ro
set gdefault
set hidden
set ignorecase
set incsearch
set keymodel=startsel
set laststatus=2
set lazyredraw
set list
set listchars=tab:→\ ,trail:·
set modeline
set mouse=a
set nojoinspaces
set noshowmode
set number
set selectmode=
set shiftwidth=4
set showcmd
set smartcase
set softtabstop=4
set splitbelow
set splitright
set switchbuf=useopen,usetab
set tabstop=4
set title
set ttimeout
set ttimeoutlen=50
set undodir=~/.cache/vim//
set undofile
set viminfo='100,<50,f1,h,n~/.cache/vim/viminfo,s10
set whichwrap=b,s,h,l,<,>,~,[,]
set wildmenu


"---------------------------------------
" Plugin settings
"---------------------------------------

let g:ctrlp_user_command = 'find -L %s
\   -name .cache -prune -o
\   -name .git -prune -o
\   -name .hg -prune -o
\   -name .svn -prune -o
\   -name node_modules -prune -o
\   \( -type d -o -type f -o -type l \)
\   \( -type d -printf "%%p/\n" -o -print \)
\   2>/dev/null'

let g:lightline = {
\   'colorscheme': 'wombat',
\}

let g:NERDCommentEmptyLines = 1
let g:NERDDefaultAlign = 'left'
let g:NERDSpaceDelims = 1

let g:netrw_banner = 0
let g:netrw_home = $HOME.'/.cache/vim'
let g:netrw_liststyle = 3

let g:snipMate = { 'snippet_version' : 1 }


"---------------------------------------
" Colour scheme
"---------------------------------------

colorscheme torte

highlight ColorColumn ctermbg=DarkGray guibg=#333333
highlight Folded ctermbg=235 guibg=#111111
highlight LineNr ctermfg=DarkGray guifg=#444444


"===============================================================================
" Key mappings
"===============================================================================

let mapleader = ','

" ,[0-9]*
nmap ,0t :set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab listchars-=tab:-\   listchars+=tab:\ \ <CR>
nmap ,1t :set tabstop=1 softtabstop=1 shiftwidth=1 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,2t :set tabstop=2 softtabstop=2 shiftwidth=2 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,3t :set tabstop=3 softtabstop=3 shiftwidth=3 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,4t :set tabstop=4 softtabstop=4 shiftwidth=4 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,5t :set tabstop=5 softtabstop=5 shiftwidth=5 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,6t :set tabstop=6 softtabstop=6 shiftwidth=6 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,7t :set tabstop=7 softtabstop=7 shiftwidth=7 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,8t :set tabstop=8 softtabstop=8 shiftwidth=8 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>

nmap ,0T :setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab listchars-=tab:-\   listchars-=tab:-\ <CR>
nmap ,1T :setlocal tabstop=1 softtabstop=1 shiftwidth=1 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,2T :setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,3T :setlocal tabstop=3 softtabstop=3 shiftwidth=3 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,4T :setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,5T :setlocal tabstop=5 softtabstop=5 shiftwidth=5 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,6T :setlocal tabstop=6 softtabstop=6 shiftwidth=6 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,7T :setlocal tabstop=7 softtabstop=7 shiftwidth=7 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>
nmap ,8T :setlocal tabstop=8 softtabstop=8 shiftwidth=8 expandtab   listchars-=tab:\ \  listchars+=tab:-\ <CR>

" ,b*
nnoremap ,bn :bnext<CR>
nnoremap ,bp :bprevious<CR>

" ,dr - Remove DOS line endings
nmap <silent> ,dr :call <SID>PreserveCursor('%s/\r$//')<CR>

" ,ds - Delete trailing spaces from blank lines
nmap <silent> ,ds :call <SID>PreserveCursor('%s/^\s\+$//e')<CR>

" ,dt - Delete trailing spaces from all lines
nmap <silent> ,dt :call <SID>PreserveCursor('%s/\s\+$//e')<CR>

" ,o
nmap <silent> ,os :edit $HOME/.vim/snippets<CR>
nmap <silent> ,ov :edit $HOME/.vimrc<CR>

" ,p*
noremap <silent> ,pc :PlugClean<CR>
noremap <silent> ,pi :PlugInstall<CR>
noremap <silent> ,pr :source $MYVIMRC<CR>

noremap <silent> ,pu
\   :PlugUpgrade<CR>
\   :PlugUpdate --sync<CR>

" ,q
nmap <silent> ,q :q<CR>
nmap <silent> ,Q :qa<CR>

" ,s*
nmap <silent> ,sh         :split<CR>
nmap <silent> ,sv         :vsplit<CR>
nmap <silent> ,s<Left>    :leftabove  :vsplit<CR>
nmap <silent> ,s<Down>    :belowright :split<CR>
nmap <silent> ,s<Up>      :aboveleft  :split<CR>
nmap <silent> ,s<Right>   :rightbelow :vsplit<CR>

" ,t* - Toggle
nmap <silent> ,th :set hlsearch!<CR>
nmap <silent> ,tn :set number!<CR>
nmap <silent> ,tp :set paste!<CR>
nmap <silent> ,tw :set wrap!<CR>

" ;
nnoremap ; :
vnoremap ; :

" -
nmap - :Explore<CR>
nmap _ :Vexplore!<CR>

" < > (Keep selection when indenting)
xnoremap < <gv
xnoremap > >gv

" Ctrl-A
noremap <C-A> ggvG$
inoremap <C-A> <C-O>gg<C-O>vG$
cnoremap <C-A> <C-C>ggvG$
onoremap <C-A> <C-C>ggvG$
snoremap <C-A> <C-C>ggvG$
xnoremap <C-A> <C-C>ggvG$

" Ctrl-S
noremap  <silent> <C-S> :wall<CR>
vnoremap <silent> <C-S> <C-C>:wall<CR>
inoremap <silent> <C-S> <Esc>:wall<CR>gi

" Ctrl-Tab / Ctrl-Shift-Tab
" The 'set' mappings force Vim to use 'ttimeout' not 'timeout' for the Esc key
set <F30>=[1;5I
set <F31>=[1;6I
nnoremap <silent> <F30> :bnext<CR>
nnoremap <silent> <F31> :bprev<CR>
inoremap <silent> <F30> <C-o>:bnext<CR>
inoremap <silent> <F31> <C-o>:bprev<CR>

" Ctrl-Alt-<Arrows>
nnoremap <silent> <C-M-Up> <C-w><Up>
nnoremap <silent> <C-M-Down> <C-w><Down>
nnoremap <silent> <C-M-Left> <C-w><Left>
nnoremap <silent> <C-M-Right> <C-w><Right>
inoremap <silent> <C-M-Up> <C-o><C-w><Up>
inoremap <silent> <C-M-Down> <C-o><C-w><Down>
inoremap <silent> <C-M-Left> <C-o><C-w><Left>
inoremap <silent> <C-M-Right> <C-o><C-w><Right>

" Ctrl-Shift-<Arrows>
nnoremap <silent> <C-S-Up> :<C-u>call <SID>MoveLineUp('.', '')<CR>
nnoremap <silent> <C-S-Down> :<C-u>call <SID>MoveLineDown('.', '')<CR>
inoremap <silent> <C-S-Up> <C-o>:<C-u>call <SID>MoveLineUp('.', '')<CR>
inoremap <silent> <C-S-Down> <C-o>:<C-u>call <SID>MoveLineDown('.', '')<CR>
vnoremap <silent> <C-S-Up> :<C-u>call <SID>MoveLineUp("'<", "'<,'>")<CR>:normal gv<CR>
vnoremap <silent> <C-S-Down> :<C-u>call <SID>MoveLineDown("'>", "'<,'>")<CR>:normal gv<CR>

" F5 - Run macro @q (which can be quickly recorded with 'qq')
nnoremap <F5> @q
vnoremap <F5> @q

" Spacebar
nmap <Space> :CtrlPBuffer<CR>

" gf = Goto file under cursor (even if it doesn't exist yet)
nmap gf :e <cfile><CR>

" x - Swap (eXchange) two blocks (delete the first, select the second, press x)
vnoremap x <Esc>`.``gvP``P

" Navigate by screen lines rather than file lines (normal mode only)
nnoremap k gk
nnoremap j gj
nnoremap <Up> gk
nnoremap <Down> gj
nnoremap <Home> g0
nnoremap <End> g$

" Make ^Z undo smaller chunks at a time
" http://vim.wikia.com/wiki/Modified_undo_behavior
inoremap <BS> <C-g>u<BS>
inoremap <Del> <C-g>u<Del>
inoremap <C-W> <C-g>u<C-W>


"===============================================================================
" Commands
"===============================================================================

command! -range=% -nargs=? Retab call <SID>Retab(<line1>, <line2>, <f-args>)


"===============================================================================
" Autocommands
"===============================================================================

" Always use Unix-format new lines for new files
autocmd BufNewFile *
\   if !&readonly && &modifiable
\|      set fileformat=unix
\|  endif

" Remember cursor position for each file
" http://vim.sourceforge.net/tips/tip.php?tip_id=80
autocmd BufReadPost *
\   if expand('<afile>:p:h') !=? $TEMP
\|      if line("'\"") > 1 && line("'\"") <= line("$")
\|          let JumpCursorOnEdit_foo = line("'\"")
\|          let b:doopenfold = 1
\|          if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1))
\|              let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1
\|              let b:doopenfold = 2
\|          endif
\|          exe JumpCursorOnEdit_foo
\|      endif
\|  endif

" Need to postpone using "zv" until after reading the modelines.
autocmd BufWinEnter *
\   if exists('b:doopenfold')
"\|      exe 'normal zv'
\|      if (b:doopenfold > 1)
\|          exe '+'.1
\|      endif
\|      unlet b:doopenfold
\|  endif

" Reload Tmux config
autocmd BufWritePost .tmux.conf
\   silent exec '!tmux source $HOME/.tmux.conf \; display "Reloaded ~/.tmux.conf" 2>/dev/null'

" Reload Vim config
autocmd BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc nested
\   source $MYVIMRC
\|  if has('gui_running')
\|      source $MYGVIMRC
\|  endif

" Prevent prompts to save directory listings - https://vi.stackexchange.com/a/12326/29179
autocmd FileType netrw
\ setlocal bufhidden=delete


"===============================================================================
" Helper functions
"===============================================================================

" <Ctrl-Alt-Up/Down> swaps lines - https://vim.wikia.com/wiki/Transposing
function! <SID>MoveLineDown(line_getter, range)
    let l_num = line(a:line_getter)
    if l_num + v:count1 > line('$')
        let move_arg = '$'
    else
        let move_arg = a:line_getter.' +'.v:count1
    endif
    execute 'silent! '.a:range.'move '.move_arg
    execute 'normal! '.virtcol('.').'|'
endfunction

function! <SID>MoveLineUp(line_getter, range)
    let l_num = line(a:line_getter)
    if l_num - v:count1 - 1 < 0
        let move_arg = '0'
    else
        let move_arg = a:line_getter.' -'.(v:count1 + 1)
    endif
    execute 'silent! '.a:range.'move '.move_arg
    execute 'normal! '.virtcol('.').'|'
endfunction

" Helper to run a command while preserving cursor position & search history
" https://technotales.wordpress.com/2010/03/31/preserve-a-vim-function-that-keeps-your-state/
function! <SID>PreserveCursor(command)
    let _s=@/
    let pos = getpos('.')
    execute a:command
    let @/=_s
    call setpos('.', pos)
endfunction

" Convert mixed spaces/tabs to all spaces:
" :ReIndent       Convert 2 space indents & tabs to current shiftwidth (i.e. default 4)
" :ReIndent <N>   Convert N space indents & tabs to current shiftwidth (i.e. default 4)
" Based on https://vim.wikia.com/wiki/Super_retab
function! <SID>Retab(...)
    let origts = (a:0 >= 3 ? a:3 : 2)
    let newts = &tabstop
    silent execute a:1 . "," . a:2 . "s/^\\( \\{" . origts . "\\}\\)\\+/\\=substitute(submatch(0), ' \\{" . origts . "\\}', '\\t', 'g')"
    silent execute a:1 . "," . a:2 . "s/^\\t\\+/\\=substitute(submatch(0), '\\t', repeat(' ', " . newts . "), 'g')"
endfunction


"===============================================================================
augroup end
