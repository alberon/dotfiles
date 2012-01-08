" Make sure any autocommands are replaced not added to when reloading this file
augroup vimrc
autocmd!
"===============================================================================

" Debugging
"set verbose=9

" This is for the syntax highlighter only! --> augroup END
" Without that it doesn't highlight the rest of this file correctly...
" (The real one is at the very end of this file)

" Automatically reload this file when it is modified
autocmd! BufWritePost .vimrc source $HOME/.vimrc

" Use ~/.vim instead of ~/vimfiles on Windows (because it's the same Git repo)
if has("win32")
    set runtimepath-=$HOME/vimfiles
    set runtimepath-=$HOME/vimfiles/after
    set runtimepath^=$HOME/.vim
    set runtimepath+=$HOME/.vim/after
endif

" Vim 6.3 doesn't support the autoload syntax, so we have to use execute instead
if v:version >= 700

    " Use Pathogen to manage plugin bundles
    execute "call pathogen#infect()"

    " Automatically update the help tags so I don't have to do it manually on all my
    " computers every time I install/upgrade/remove a bundle
    execute "call pathogen#helptags()"

endif

" Helper to run a command while preserving cursor position & search history
" http://technotales.wordpress.com/2010/03/31/preserve-a-vim-function-that-keeps-your-state/
function! <SID>Preserve(command)
    " Preparation: save last search, and cursor position.
    let _s=@/
    let pos = getpos('.')
    " Do the business:
    execute a:command
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call setpos('.', pos)
endfunction

" Behave more like a Windows program
runtime mswin.vim

" Use visual mode instead of select mode (for both keyboard and mouse)
set selectmode=

" Use visual mode for Ctrl-A (select all) too
noremap <C-A> ggvG$
inoremap <C-A> <C-O>gg<C-O>vG$
cnoremap <C-A> <C-C>ggvG$
onoremap <C-A> <C-C>ggvG$
if v:version >= 700
    snoremap <C-A> <C-C>ggvG$
    xnoremap <C-A> <C-C>ggvG$
endif

" Allow pressing arrows (without shift) in visual mode
" This gives the best of both worlds - you can use shift+arrow in insert mode to
" quickly start visual mode (instead of <Esc>v<Arrow>), but still use the arrow
" keys in visual mode as normal (instead of having to hold shift)
" TODO: Learn to use hjkl instead of the arrow keys so this isn't an issue!
set keymodel-=stopsel

" Use ; instead of : for commands (don't need to press shift so much)
nnoremap ; :
vnoremap ; :

" Use , as the leader for my own keyboard shortcuts
let mapleader = ","

"-------------------------------------------------------------------------------
" Start <Leader> shortcuts
"-------------------------------------------------------------------------------

" Alternate files (a.vim)
let g:alternateExtensions_php = "tpl"
let g:alternateExtensions_tpl = "php"
nmap <Leader>a :AT<CR>

" Buffers (list and open prompt ready to switch)
"nmap <Leader>b :buffers<CR>:buffer 
" Buffers (FuzzyFinder)
nmap <Leader>b :FufBuffer<CR>

" NERD Commenter = <Leader>c* (e.g. c, n, u)

" DirDiff = <Leader>d* (k, j, p, g)

" Delete spaces from otherwise empty lines
nmap <silent> <Leader>ds :call <SID>Preserve('%s/^\s\+$//e')<CR>

" Delete trailing spaces
nmap <silent> <Leader>dt :call <SID>Preserve('%s/\s\+$//e')<CR>

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
" TODO: Open the snippets file that corresponds to the current file - list them
" only if there's more than one to choose from
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

"-------------------------------------------------------------------------------
" End <Leader> shortcuts
"-------------------------------------------------------------------------------

" Ctrl+direction to switch buffers
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Make % jump between XML tags as well as normal brackets
runtime macros/matchit.vim

" Enable syntax highlighting
syntax on

" Change color scheme
" Use silent! because the Git Bash version of Vim doesn't include colour schemes
silent! colorscheme torte

" Make the line numbers less visible
hi LineNr guifg=#444444

" Make folded sections easier to read (dark grey instead of light background)
hi Folded guibg=#111111

" Highlight just *after* columns 80 and 120
if version >= 703
    set colorcolumn=81,121
    hi ColorColumn ctermbg=DarkGray guibg=#333333
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
filetype plugin on

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

" Always use Unix-format new lines for new files
au BufNewFile * if !&readonly && &modifiable | set fileformat=unix | endif

" Remember cursor position for each file
" http://vim.sourceforge.net/tips/tip.php?tip_id=80
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
"\       exe "normal zv" |
\       if (b:doopenfold > 1) |
\           exe  "+".1 |
\       endif |
\       unlet b:doopenfold |
\   endif

" Use 4 spaces to indent (use ":ret" to convert tabs to spaces)
set expandtab tabstop=4 softtabstop=4 shiftwidth=4

" Knowledgebase files use 3 spaces to line comments up under list items
autocmd FileType knowledgebase setlocal tabstop=3 shiftwidth=3 softtabstop=3

" Tab2Space - http://vim.wikia.com/wiki/Super_retab
command! -range=% -nargs=0 Tab2Space execute "<line1>,<line2>s/^\\t\\+/\\=substitute(submatch(0), '\\t', repeat(' ', ".&ts."), 'g')"

" Space2Tab - http://vim.wikia.com/wiki/Super_retab
command! -range=% -nargs=0 Space2Tab execute "<line1>,<line2>s/^\\( \\{".&ts."\\}\\)\\+/\\=substitute(submatch(0), ' \\{".&ts."\\}', '\\t', 'g')"

" Convert mixed spaces/tabs to all spaces:
" :ReIndent       Convert 2 space indents & tabs to current shiftwidth (i.e. default 4)
" :ReIndent <N>   Convert N space indents & tabs to current shiftwidth (i.e. default 4)
" Based on http://vim.wikia.com/wiki/Super_retab
function! <SID>ReIndent(...)
    let origts = (a:0 >= 3 ? a:3 : 2)
    let newts = &tabstop
    silent execute a:1 . "," . a:2 . "s/^\\( \\{" . origts . "\\}\\)\\+/\\=substitute(submatch(0), ' \\{" . origts . "\\}', '\\t', 'g')"
    silent execute a:1 . "," . a:2 . "s/^\\t\\+/\\=substitute(submatch(0), '\\t', repeat(' ', " . newts . "), 'g')"
endfunction

command! -range=% -nargs=? ReIndent call <SID>ReIndent(<line1>, <line2>, <f-args>)

" Case-insensitive search unless there's a capital letter (then case-sensitive)
set ignorecase
set smartcase

" Highlight search results as you type
"set hlsearch
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

" Keep 5 lines/columns of text on screen around the cursor
set scrolloff=5
set sidescroll=1
set sidescrolloff=5

" Enable mouse support in all modes
if has("mouse")
    set mouse=a
endif

" Automatically fold when markers are used
if has("folding")
    set foldmethod=marker
endif

" Remove all the ---s after a fold to make it easier to read
set fillchars=vert:\|,fold:\ 

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

" Except in snippet files because they have to use tabs
au FileType snippet,snippets setl listchars+=tab:\ \ 

" Use the temp directory for all backups and swap files, instead of cluttering
" up the filesystem with .*.swp and *~ files
" Note the trailing // means include the full path of the current file so
" files with the same name in different folders don't conflict
set backupdir=~/tmp/vim//
set directory=~/tmp/vim//
if version >= 703
    set undodir=~/tmp/vim//
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

    function! <SID>MyPaste()

        " Set to character-wise
        " http://vim.wikia.com/wiki/Unconditional_linewise_or_characterwise_paste
        let reg_type = getregtype("+")
        call setreg("+", getreg("+"), "v")

        " Use the bundled paste command
        call paste#Paste()

        " Reset line/character-wise
        call setreg("+", getreg("+"), reg_type)

    endfunction

    " Explanation:
    " <C-g>u                      Set undo point
    " <C-o>:call MyPaste()<CR>    Call the function above
    " <C-g>u                      Set another undo point
    " 2010-06-19 Removed the final undo point because it seems to cause problems
    "            when ThinkingRock is open...
    "inoremap <C-V> <C-g>u<C-o>:call MyPaste()<CR><C-g>u
    inoremap <C-V> <C-g>u<C-o>:call <SID>MyPaste()<CR>

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
" Added silent! to prevent error messages if the file & directory has been deleted
"set autochdir
autocmd BufEnter * execute "silent! chdir ".escape(expand("%:p:h"), ' ')

" gf = Goto file under cursor even if it doesn't exist yet
nmap gf :e <cfile><CR>

" Keep selection when indenting block-wise
if version >= 700
    xnoremap < <gv
    xnoremap > >gv
endif

" <Ctrl-Alt-Up/Down> swaps lines
" http://vim.wikia.com/wiki/Transposing
function! <SID>MoveLineUp()
    call <SID>MoveLineOrVisualUp(".", "")
endfunction

function! <SID>MoveLineDown()
    call <SID>MoveLineOrVisualDown(".", "")
endfunction

function! <SID>MoveVisualUp()
    call <SID>MoveLineOrVisualUp("'<", "'<,'>")
    normal gv
endfunction

function! <SID>MoveVisualDown()
    call <SID>MoveLineOrVisualDown("'>", "'<,'>")
    normal gv
endfunction

function! <SID>MoveLineOrVisualUp(line_getter, range)
    let l_num = line(a:line_getter)
    if l_num - v:count1 - 1 < 0
        let move_arg = "0"
    else
        let move_arg = a:line_getter." -".(v:count1 + 1)
    endif
    call <SID>MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
endfunction

function! <SID>MoveLineOrVisualDown(line_getter, range)
    let l_num = line(a:line_getter)
    if l_num + v:count1 > line("$")
        let move_arg = "$"
    else
        let move_arg = a:line_getter." +".v:count1
    endif
    call <SID>MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
endfunction

function! <SID>MoveLineOrVisualUpOrDown(move_arg)
    let col_num = virtcol(".")
    execute "silent! ".a:move_arg
    execute "normal! ".col_num."|"
endfunction

nnoremap <silent> <C-A-Up> :<C-u>call <SID>MoveLineUp()<CR>
nnoremap <silent> <C-A-Down> :<C-u>call <SID>MoveLineDown()<CR>
inoremap <silent> <C-A-Up> <C-o>:<C-u>call <SID>MoveLineUp()<CR>
inoremap <silent> <C-A-Down> <C-o>:<C-u>call <SID>MoveLineDown()<CR>
vnoremap <silent> <C-A-Up> :<C-u>call <SID>MoveVisualUp()<CR>
vnoremap <silent> <C-A-Down> :<C-u>call <SID>MoveVisualDown()<CR>

" Auto-complete (X)HTML tags with Ctrl-Hyphen
au Filetype * runtime closetag.vim

" Use Sparkup to generate HTML quickly (Ctrl-E)
au Filetype * runtime sparkup.vim

" Highlight long lines:
" :Long       Highlight after 80 characters
" :Long <N>   Highlight after <N> characters
" :NoLong     Remove highlighting
function! <SID>HighlightLongLines(...)

    if exists('w:long_line_match')
        silent! call matchdelete(w:long_line_match)
        unlet w:long_line_match
    endif

    let len = (a:0 == 0 ? 80 : a:1)
    if len > 0
        let w:long_line_match = matchadd('ErrorMsg', '\%>'.len.'v.\+', -1)
    endif

endfunction

command! -nargs=? LongLines call <SID>HighlightLongLines(<f-args>)
command! NoLongLines call <SID>HighlightLongLines(0)

" Cycle through buffers
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

" FuzzyFinder - if search begins with a space do a recursive search
if v:version >= 700
    let g:fuf_abbrevMap = {
        \   "^ " : [ "**/", ],
        \}
endif

" Remember mark positions
set viminfo+=f1

" Indenting
set autoindent
"set smartindent    " Removed because it prevent #comments being indented
"set cindent        " Removed because it indents things when it shouldn't
"set cinoptions-=0# " So #comments aren't unindented with cindent
set formatoptions+=ro " Duplicate comment lines when pressing enter

" snipMate config
if v:version >= 700
    let snips_author = 'Dave James Miller'
    if !exists('g:snipMate')
      let g:snipMate = {}
    endif
    let g:snipMate['scope_aliases'] = {
        \   'cpp':      'c',
        \   'cs':       'c',
        \   'eruby':    'html',
        \   'html':     'htmlonly',
        \   'mxml':     'actionscript',
        \   'objc':     'c',
        \   'php':      'html',
        \   'scss':     'css',
        \   'smarty':   'html',
        \   'ur':       'html',
        \   'xhtml':    'htmlonly,html',
        \}
endif

" Use OS clipboard by default
"set clipboard+=unnamed

" No GUI toolbar - I never use it
set guioptions-=T

" Keep scrollbars on the right - the left scrollbar doesn't work with my
" gaming mouse software
set guioptions-=L

" Maximize GUI window automatically
function! <SID>SetGuiPos()

    " If there's a .gvimrc_size file use that instead so it can override
    " this setting
    let include = $HOME . "/.gvimrc_size"

    if filereadable(include)
        " e.g.
        " winpos 0 0
        " set lines=71 columns=155
        exe "source " . include
    elseif has("win32")
        simalt ~x
    endif

endfunction

autocmd GUIEnter * exe <SID>SetGuiPos()

" <Ctrl-S> shows save dialog for new files
noremap <silent> <C-s> :if expand("%") == ""<CR>:browse confirm w<CR>:else<CR>:confirm w<CR>:endif<CR>
inoremap <silent> <C-s> <C-o>:if expand("%") == ""<CR>:browse confirm w<CR>:else<CR>:confirm w<CR>:endif<CR>
vnoremap <silent> <C-s> <C-c>:if expand("%") == ""<CR>:browse confirm w<CR>:else<CR>:confirm w<CR>:endif<CR>

" <Ctrl-O> shows open dialog
inoremap <silent> <C-o> <C-o>:browse e<CR>

" <Ctrl-F> shows find dialog
inoremap <silent> <C-f> <C-o>:promptfind<CR>

" Sort CSS properties alphabetically
command! SortCSS silent! call <SID>Preserve("normal \"?{<CR>jV/^\s*\}<CR>k:sort<CR>\"")

" Sort .snippets files alphabetically
function! <SID>SortSnippets()
    " Join all lines together
    %s/\n/__NEWLINE__
    " Split by where the snippets start, so each snippet is one line
    %s/__NEWLINE__snippet /__NEWLINE__\rsnippet 
    " Remove any __NEWLINE__s that are already followed by a new line
    %s/__NEWLINE__\n/\r
    " Delete the extra blank line that gets added at the end
    $d
    " Sort the lines alphabetically
    sort
    " Split the snippets into separate lines again
    %s/__NEWLINE__/\r
endfunction

command! SortSnippets silent! call <SID>Preserve("call <SID>SortSnippets()")

" Show tab bar always
if v:version >= 700
    set showtabline=2
endif

" Ctrl-T to open a new tab
map <C-t> :tabnew<cr>
nmap <C-t> :tabnew<cr>
imap <C-t> <ESC>:tabnew<cr>

" Cycle through tabs with Ctrl-Tab as well as Ctrl-PageDn/Up
"map <C-Tab> :tabnext<CR>
"map <C-S-Tab> :tabprev<CR>
"inoremap <C-Tab> <C-O>:tabnext<CR>
"inoremap <C-S-Tab> <C-O>:tabprev<CR>

" Move tabs around with Alt-PageDn/Up
function! <SID>TabLeft()
   let tab_number = tabpagenr() - 1
   if tab_number == 0
      execute "tabm" tabpagenr('$') - 1
   else
      execute "tabm" tab_number - 1
   endif
endfunction

function! <SID>TabRight()
   let tab_number = tabpagenr() - 1
   let last_tab_number = tabpagenr('$') - 1
   if tab_number == last_tab_number
      execute "tabm" 0
   else
      execute "tabm" tab_number + 1
   endif
endfunction

map <silent> <A-PageUp> :call <SID>Preserve("execute <SID>TabLeft()")<CR>
map <silent> <A-PageDown> :call <SID>Preserve("execute <SID>TabRight()")<CR>

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
    " Wrapped in execute for Vim 6.3 support
    execute
        \ 'for bufnr in bufnrlist'
        \ '|  if getbufvar(bufnr, "&modified")'
        \ '|      let label .= "+"'
        \ '|      break'
        \ '|  endif'
        \ '|endfor'

    return label
endfunction

if v:version >= 700
    set guitablabel=%{GuiTabLabel()}
endif

" :w!! to save using sudo
" http://blog.stebalien.com/2009/08/write-file-as-root-from-non-root-vim.html
" TODO Make this a command (:W!) instead of a mapping
"cmap w!! w !sudo tee % >/dev/null<CR>:e!<CR><CR>

" Make increment/decrement work in Windows using alt
noremap <M-a> <C-a>
noremap <M-x> <C-x>

"===============================================================================
" Finish the autocommands group
augroup END
