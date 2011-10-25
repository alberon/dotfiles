" Debugging
"set verbose=9

" Behave more like a Windows program
source $VIMRUNTIME/mswin.vim

" Except the xterm selection method is better
behave xterm

" Use Pathogen to manage plugin bundles
call pathogen#infect()
call pathogen#helptags()

" Use ; instead of : for commands (don't need to press shift so much)
nnoremap ; :

" Use , as the leader for my own keyboard shortcuts
let mapleader = ","

" Sort CSS properties alphabetically
nmap <silent> <Leader>az ?{<CR>jV/^\s*\}?$<CR>k:sort<CR>:noh<CR>

" Buffers (list and open prompt ready to switch)
"nmap <Leader>b :buffers<CR>:buffer 
" Buffers (Buffer Explorer)
nmap <Leader>b :BufExplorer<CR>

" NERD Commenter = <Leader>c (then various letters - e.g. cc, cu, cn)

" Delete spaces from otherwise empty lines
nmap <silent> <Leader>ds :%s/^\s\+$<CR>

" Delete trailing spaces (be careful with this - e.g. in .vimrc there are
" lines that need to end with spaces to work!)
nmap <silent> <Leader>dt :%s/\s\+$<CR>

" NERDtree
nmap <silent> <Leader>e :NERDTree<CR>

" Open URL in Firefox = <Leader>ff (see .gvimrc)

" Goto buffer
nmap <silent> <Leader>gb :FufBuffer<CR>

" Goto file
nmap <silent> <Leader>gf :FufFile<CR>

" Insert Date (DDD D MMM YYYY)
nmap <silent> <Leader>id a<C-R>=strftime("%a %#d %b %Y")<CR>

" Disable search highlight
nmap <silent> <Leader>n :nohlsearch<CR>

" Open .vimrc / .gvimrc
nmap <silent> <Leader>ov :edit $VIM/.vimrc<CR>
nmap <silent> <Leader>og :edit $VIM/.gvimrc<CR>

" Quit
nmap <silent> <Leader>q :q<CR>
nmap <silent> <Leader>Q :wq<CR>

" Split screen in various ways (with a new file rather than the same file -
" it's rare that I want to edit the current buffer twice, and there's always
" <C-W><C-V> for that)
nmap <silent> <Leader>ss         :new<CR>
nmap <silent> <Leader>sv         :vnew<CR>
nmap <silent> <Leader>sh         :leftabove  :vnew<CR>
nmap <silent> <Leader>sj         :belowright :new<CR>
nmap <silent> <Leader>sk         :aboveleft  :new<CR>
nmap <silent> <Leader>sl         :rightbelow :vnew<CR>
nmap <silent> <Leader>s<Left>    :leftabove  :vnew<CR>
nmap <silent> <Leader>s<Down>    :belowright :new<CR>
nmap <silent> <Leader>s<Up>      :aboveleft  :new<CR>
nmap <silent> <Leader>s<Right>   :rightbelow :vnew<CR>

" Change the tab size
nmap <silent> <Leader>1t :set tabstop=1 softtabstop=1 shiftwidth=1<CR>
nmap <silent> <Leader>2t :set tabstop=2 softtabstop=2 shiftwidth=2<CR>
nmap <silent> <Leader>3t :set tabstop=3 softtabstop=3 shiftwidth=3<CR>
nmap <silent> <Leader>4t :set tabstop=4 softtabstop=4 shiftwidth=4<CR>
nmap <silent> <Leader>5t :set tabstop=5 softtabstop=5 shiftwidth=5<CR>
nmap <silent> <Leader>6t :set tabstop=6 softtabstop=6 shiftwidth=6<CR>
nmap <silent> <Leader>7t :set tabstop=7 softtabstop=7 shiftwidth=7<CR>
nmap <silent> <Leader>8t :set tabstop=8 softtabstop=8 shiftwidth=8<CR>

" Switch to using tabs instead of spaces to indent (or back again)
nmap <silent> <Leader>t :set noexpandtab<CR>
nmap <silent> <Leader>T :set expandtab<CR>

" Write
nmap <silent> <Leader>w :w<CR>

" Graphical undo
nmap <silent> <Leader>z :GundoToggle<CR>

" Ctrl+direction to switch buffers
nnoremap <C-h>      <C-w>h
nnoremap <C-j>      <C-w>j
nnoremap <C-k>      <C-w>k
nnoremap <C-l>      <C-w>l

" Make % jump between XML tags as well as normal brackets
runtime macros/matchit.vim

" Color Scheme
syntax on
colorscheme torte

" Make the line numbers less visible
hi LineNr guifg=#444444

" Make folded sections easier to read (dark grey instead of light)
hi Folded guibg=#111111

" Highlight just after 80 and 120 columns (standard widths)
if version >= 703
    set colorcolumn=81,121
    hi ColorColumn guibg=#333333
endif

" PHP syntax highlighting settings
"let php_sql_query = 1
"let php_htmlInStrings = 1
let php_smart_members = 1
"let php_highlight_quotes = 1
let php_alt_construct_parents = 1
let php_sync_method = 0            " Sync from file start
let php_show_semicolon_error = 0   " This causes errors with /* */ multiline comments

" Use UTF-8 for everything, but no byte-order mark because it breaks things
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,default,latin1
set nobomb

" File type detection
"TODO Make indenting work to my satisfaction, especially in PHP
"filetype plugin indent on
filetype plugin on

augroup CustomFileTypes

    " Clear Group
    au!

    " AutoIt syntax
    au BufNewFile,BufRead *.au3 setlocal ft=autoit

    " Standard ML syntax
    au BufNewFile,BufRead *.ml,*.sml setlocal ft=sml

    " Java syntax
    au BufNewFile,BufRead *.class setlocal ft=class
    au BufNewFile,BufRead *.jad setlocal ft=java

    " CSV files
    au BufNewFile,BufRead *.csv setf csv

    " CakePHP
    au BufNewFile,BufRead *.thtml,*.ctp setf php

    " Drupal
    au BufNewFile,BufRead *.module,*.install set ft=php
    au BufNewFile,BufRead *.info setf dosini

    " Text files
    au BufNewFile,BufRead *.txt setf txt

augroup END

" Always use Unix-format new lines for new files
au BufNewFile * if !&readonly && &modifiable | set fileformat=unix | endif

" Remember cursor position for each file
" http://vim.sourceforge.net/tips/tip.php?tip_id=80
augroup JumpCursorOnEdit
au!

autocmd BufReadPost *
\   if expand("<afile>:p:h") !=? $TEMP |
\       if line("'\"") > 1 && line("'\"") <= line("$") |
\           let JumpCursorOnEdit_foo = line("'\"") |
\           let b:doopenfold = 1 |
\           if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
\               let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
\               let b:doopenfold = 2 |
\           endif |
\           exe JumpCursorOnEdit_foo |
\       endif |
\   endif

" Need to postpone using "zv" until after reading the modelines.
autocmd BufWinEnter *
\   if exists("b:doopenfold") |
\       exe "normal zv" |
\       if (b:doopenfold > 1) |
\           exe  "+".1 |
\       endif |
\       unlet b:doopenfold |
\   endif

augroup END

" Use 4 spaces to indent (use ":ret" to convert tabs to spaces)
set expandtab tabstop=4 softtabstop=4 shiftwidth=4

" Knowledgebase files use 3 spaces to line comments up under list items
autocmd FileType knowledgebase set tabstop=3 shiftwidth=3 softtabstop=3

" Tab2Space - http://vim.wikia.com/wiki/Super_retab
command! -range=% -nargs=0 Tab2Space execute "<line1>,<line2>s/^\\t\\+/\\=substitute(submatch(0), '\\t', repeat(' ', ".&ts."), 'g')"

" Space2Tab - http://vim.wikia.com/wiki/Super_retab
command! -range=% -nargs=0 Space2Tab execute "<line1>,<line2>s/^\\( \\{".&ts."\\}\\)\\+/\\=substitute(submatch(0), ' \\{".&ts."\\}', '\\t', 'g')"

" Convert mixed spaces/tabs to all spaces:
" :ReIndent       Convert 2 space indents & tabs to current shiftwidth (i.e. default 4)
" :ReIndent <N>   Convert N space indents & tabs to current shiftwidth (i.e. default 4)
" Based on http://vim.wikia.com/wiki/Super_retab
fun ReIndent(...)
    let origts = (a:0 >= 3 ? a:3 : 2)
    let newts = &tabstop
    silent execute a:1 . "," . a:2 . "s/^\\( \\{" . origts . "\\}\\)\\+/\\=substitute(submatch(0), ' \\{" . origts . "\\}', '\\t', 'g')"
    silent execute a:1 . "," . a:2 . "s/^\\t\\+/\\=substitute(submatch(0), '\\t', repeat(' ', " . newts . "), 'g')"
endfun

command -range=% -nargs=? ReIndent call ReIndent(<line1>, <line2>, <f-args>)

" Make > and < shift to a multiple of N instead of just adding/removing N spaces
set shiftround

" Case-insensitive search unless there's a capital letter (then case-sensitive)
set ignorecase
set smartcase

" Highlight searches as you type
set hlsearch
set incsearch

" Default to replacing all occurrences in :s (swaps the meaning of the /g flag)
set gdefault

" Wrap to the next line for all commands that move left/right
set whichwrap=b,s,h,l,<,>,~,[,]

" Show line numbers
set number

" Always show the status line
set laststatus=2

" Open split windows below/right instead of above/left by default
set splitbelow
set splitright

" Shorten some status messages, and don't show the intro splash screen
set shortmess=ilxtToOI

" Use dialogs to confirm things like quiting without saving, instead of failing
set confirm

" Don't put two spaces between sentences
set nojoinspaces

" Some old indenting options... TODO: Delete if I don't need them...
"set autoindent
"set smartindent
"set copyindent
"set nocopyindent " Changed because in Vim 7.2 autoindent seems to have started using a tab for the last char even with expandtab on
"set cinoptions=0{,0},0),:,!^F,o,O,e " Removed 0#
"set formatoptions+=ro " Duplicate comment lines when pressing enter

" Always write a separate backup, don't use renaming because it resets the
" executable flag when editing over Samba
set backupcopy=yes

" Don't hide the mouse when typing
set nomousehide

" Remember 50 history items instead of 20
set history=50

" Show position in the file in the status line
set ruler

" Show selection size
set showcmd

" Show a menu when autocompleting commands
set wildmenu

" Don't redraw the screen while executing macros, etc.
set lazyredraw

" Enable modeline support, because Debian disables it (for security reasons)
set modeline

" Allow hidden buffers, so I can move between buffers without having to save first
set hidden

" Show the filename in the titlebar when using console vim
set title

" Keep 3 lines of text on screen above/below the cursor
set scrolloff=3

" Enable mouse support in all modes
if has("mouse")
    set mouse=a
endif

" Automatically fold when markers are used
if has("folding")
    set foldmethod=marker
endif

" Keep an undo history after closing Vim (Vim 7.3+)
if version >= 703
    set undofile
endif

" In case I ever use encryption, Blowfish is more secure (but requires Vim 7.3+)
if version >= 703
    set cryptmethod=blowfish
endif

" Show tabs and trailing spaces...
set list
set listchars=tab:>\ ,trail:.

" Use the temp directory for all backups and swap files, instead of cluttering
" up the filesystem with .*.swp and *~ files
" Note the trailing // means include the full path of the current file so
" files with the same name in different folders don't conflict
if has("win32")
    " Windows
    set backupdir=d:/Temp/Vim//
    set directory=d:/Temp/Vim//
    if version >= 703
        set undodir=d:/Temp/Vim//
    endif
else
    " Linux
    set backupdir=~/tmp/vim//
    set directory=~/tmp/vim//
    if version >= 703
        set undodir=~/tmp/vim//
    endif
endif

" Make ^Z undo smaller chunks at a time
" http://vim.wikia.com/wiki/Modified_undo_behavior
inoremap <BS> <C-g>u<BS>
inoremap <Del> <C-g>u<Del>
inoremap <C-W> <C-g>u<C-W>

" Make paste an undoable action, rather than joining it with any text that's typed in
" Also use character-wise instead of line-wise paste, so it goes where the
" cursor is instead of on the line above
if exists("*paste#Paste")

    func! MyPaste()

        " Set to character-wise
        " http://vim.wikia.com/wiki/Unconditional_linewise_or_characterwise_paste
        let reg_type = getregtype("+")
        call setreg("+", getreg("+"), "v")

        " Use the bundled paste command
        call paste#Paste()

        " Reset line/character-wise
        call setreg("+", getreg("+"), reg_type)

    endfunc

    " Explanation:
    " <C-g>u                      Set undo point
    " <C-o>:call MyPaste()<CR>    Call the function above
    " <C-g>u                      Set another undo point
    " 2010-06-19 Removed the final undo point because it seems to cause problems
    "            when ThinkingRock is open...
    "inoremap <C-V> <C-g>u<C-o>:call MyPaste()<CR><C-g>u
    inoremap <C-V> <C-g>u<C-o>:call MyPaste()<CR>

endif

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

" Automatically cd to the directory that the current file is in
" This first option is built in but doesn't quite work as you'd expect - see
" http://stackoverflow.com/questions/164847/what-is-in-your-vimrc/652632#652632
"set autochdir
" This ones works, but I'm trying Vim without it for a while to see if it
" makes things like FuzzyFinder better by having a non-changing root
"autocmd BufEnter * execute "chdir ".escape(expand("%:p:h"), ' ')

" gf = Goto file under cursor even if it doesn't exist yet
nmap gf :e <cfile><CR>

" Keep selection when indenting block-wise
if version >= 700
    xnoremap < <gv
    xnoremap > >gv
endif

" <Ctrl-Alt-Up/Down> swaps lines
" http://vim.wikia.com/wiki/Transposing
function! MoveLineUp()
    call MoveLineOrVisualUp(".", "")
endfunction

function! MoveLineDown()
    call MoveLineOrVisualDown(".", "")
endfunction

function! MoveVisualUp()
    call MoveLineOrVisualUp("'<", "'<,'>")
    normal gv
endfunction

function! MoveVisualDown()
    call MoveLineOrVisualDown("'>", "'<,'>")
    normal gv
endfunction

function! MoveLineOrVisualUp(line_getter, range)
    let l_num = line(a:line_getter)
    if l_num - v:count1 - 1 < 0
        let move_arg = "0"
    else
        let move_arg = a:line_getter." -".(v:count1 + 1)
    endif
    call MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
endfunction

function! MoveLineOrVisualDown(line_getter, range)
    let l_num = line(a:line_getter)
    if l_num + v:count1 > line("$")
        let move_arg = "$"
    else
        let move_arg = a:line_getter." +".v:count1
    endif
    call MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
endfunction

function! MoveLineOrVisualUpOrDown(move_arg)
    let col_num = virtcol(".")
    execute "silent! ".a:move_arg
    execute "normal! ".col_num."|"
endfunction

nnoremap <silent> <C-A-Up> :<C-u>call MoveLineUp()<CR>
nnoremap <silent> <C-A-Down> :<C-u>call MoveLineDown()<CR>
inoremap <silent> <C-A-Up> <C-o>:<C-u>call MoveLineUp()<CR>
inoremap <silent> <C-A-Down> <C-o>:<C-u>call MoveLineDown()<CR>
vnoremap <silent> <C-A-Up> :<C-u>call MoveVisualUp()<CR>
vnoremap <silent> <C-A-Down> :<C-u>call MoveVisualDown()<CR>

" Auto-complete (X)HTML tags with Ctrl-Hyphen
au Filetype * runtime closetag.vim

" Use Sparkup to generate HTML quickly (Ctrl-E)
au Filetype * runtime sparkup.vim

" Highlight long lines:
" :Long       Highlight after 80 characters
" :Long <N>   Highlight after <N> characters
" :NoLong     Remove highlighting
fun HighlightLongLines(...)

    if exists('w:long_line_match')
        silent! call matchdelete(w:long_line_match)
        unlet w:long_line_match
    endif

    let len = (a:0 == 0 ? 80 : a:1)
    if len > 0
        let w:long_line_match = matchadd('ErrorMsg', '\%>'.len.'v.\+', -1)
    endif

endfun

command -nargs=? LongLines call HighlightLongLines(<f-args>)
command NoLongLines call HighlightLongLines(0)

" Cycle through buffers
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

" NERDTree config has to be in a separate file to avoid causing errors in
" older versions of Vim due to the array syntax
if version >= 700
    runtime nerdtree-config.vim
endif

" FuzzyFinder - if search begins with a space do a recursive search
let g:fuf_abbrevMap = {
    \   "^ " : [ "**/", ],
    \ }

" Remember open buffers when loading Vim with no arguments
set viminfo+=%

" Remember mark positions also
set viminfo+=f1
