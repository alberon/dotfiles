" Debugging
"set verbose=9

" Default settings block
set nocompatible

" Behave like a Windows program
source $VIMRUNTIME/mswin.vim

"================================================================================
" Append bundle paths
"================================================================================
call pathogen#runtime_append_all_bundles()

"================================================================================
" Color Scheme
"================================================================================

syntax on
colorscheme torte

" PHP Colour Scheme
"let php_sql_query = 1
"let php_htmlInStrings = 1
let php_smart_members = 1
"let php_highlight_quotes = 1
let php_alt_construct_parents = 1
let php_sync_method = 0            " Sync from file start
let php_show_semicolon_error = 0   " This causes errors with /* */ multiline comments

"================================================================================
" File type detection
"================================================================================

"filetype plugin indent on
filetype plugin on

" Note: setlocal ft= is used because the commands in filetype.vim are executed
" first, so setf is ignored. This particularly has an effect when one of the
" first 5 lines of the file start with a #, so ft=conf is used.
" TODO: Move to filetype.vim?
"       See http://bakery.cakephp.org/articles/view/turn-on-syntax-highlighting-for-editing-thtml-files-in-vim
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
au BufNewFile,BufRead *.module set ft=php

" Text files
au BufNewFile,BufRead *.txt setf txt

" Conflict markers
if version >= 700
    au BufNewFile,BufRead *
    \   if match(getline(1, min([line("$"), 100])), '^=======$') > -1
    \   && match(getline(1, min([line("$"), 100])), '^<<<<<<< ') > -1
    \   && match(getline(1, min([line("$"), 100])), '^>>>>>>> ') > -1 |
    \       setlocal syn=conflict |
    \   endif
endif

augroup END

"================================================================================
" Unix <LF> line endings
"================================================================================

" Always use Unix-format new lines, even when editing files!
" (Removed because I was making it hard for people at work to read files using Notepad!)
"au BufNewFile,BufRead * if !&readonly | set fileformat=unix | endif

" Always use Unix-format new lines for new files
au BufNewFile * if !&readonly | set fileformat=unix | endif

"================================================================================
" Remember cursor position for each file
"================================================================================

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

"================================================================================
" Indenting
"================================================================================

" Tabs (use ":ret! [numspaces]" to convert spaces to tabs)
"set noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

" 4 spaces (use ":ret" to convert tabs to spaces)
set expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Knowledgebase files use 3 spaces to line comments up under list items
autocmd FileType knowledgebase set tabstop=3 shiftwidth=3 softtabstop=3

" Tab2Space
" http://vim.wikia.com/wiki/Super_retab
command! -range=% -nargs=0 Tab2Space execute "<line1>,<line2>s/^\\t\\+/\\=substitute(submatch(0), '\\t', repeat(' ', ".&ts."), 'g')"

" Space2Tab
" http://vim.wikia.com/wiki/Super_retab
command! -range=% -nargs=0 Space2Tab execute "<line1>,<line2>s/^\\( \\{".&ts."\\}\\)\\+/\\=substitute(submatch(0), ' \\{".&ts."\\}', '\\t', 'g')"

" Convert mixed spaces/tabs to all spaces
" Based on http://vim.wikia.com/wiki/Super_retab
fun ReIndent(...)
    let origts = (a:0 >= 3 ? a:3 : 2)
    let newts = &tabstop
    silent execute a:1 . "," . a:2 . "s/^\\( \\{" . origts . "\\}\\)\\+/\\=substitute(submatch(0), ' \\{" . origts . "\\}', '\\t', 'g')"
    silent execute a:1 . "," . a:2 . "s/^\\t\\+/\\=substitute(submatch(0), '\\t', repeat(' ', " . newts . "), 'g')"
endfun

" :ReIndent       Convert 2 space indents to current shiftwidth
" :ReIndent <N>   Convert N space indents to current shiftwidth
command -range=% -nargs=? ReIndent call ReIndent(<line1>, <line2>, <f-args>)

"================================================================================
" Other Settings
"================================================================================

set ignorecase
set smartcase
set gdefault " Default to replacing all occurrences (/g) in :s
set whichwrap=b,s,h,l,<,>,~,[,]
set showbreak=~
set number
set hlsearch
set incsearch
set laststatus=2
set splitright
set shortmess=filnxtToOI
set confirm
set errorbells
set nojoinspaces
set autoindent
set smartindent
"set copyindent
set nocopyindent " Changed because in Vim 7.2 autoindent seems to have started using a tab for the last char even with expandtab on
set cinoptions=0{,0},0),:,!^F,o,O,e " Removed 0#
set formatoptions+=ro " Duplicate comment lines when pressing enter
set nowritebackup " Removed because it resets executable flag when editing over Samba
"set backup
set nobackup " Delete after writing - saves headaches with `sudo gvim`!
set nomousehide
set fileformat=unix
set history=50
set ruler
set showcmd
set wildmenu
set lazyredraw
set modeline " Debian disables it in /usr/share/vim/vim71/debian.vim

if version >= 730
    set undofile
    set colorcolumn=81,121
endif

" Use UTF-8 for everything, but no byte-order mark because it breaks things
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,default,latin1
set nobomb

" Highlight tabs
set list
set listchars=tab:>\ 

au FileType snippet set nolist

" Mouse support is not available on Cheetah
if has("mouse")
    set mouse=a
endif

" Folding is not available on Cheetah
if has("folding")
    set foldmethod=marker
endif

" Temp directory
if has("win32")
    set backupdir=d:/Temp/Vim//
    set directory=d:/Temp/Vim//
    if version >= 730
        set undodir=d:/Temp/Vim//
    endif
else
    set backupdir=~/tmp/vim//
    set directory=~/tmp/vim//
    if version >= 730
        set undodir=~/tmp/vim//
    endif
endif

"================================================================================
" Highlight trailing spaces
"================================================================================

" http://vim.wikia.com/wiki/Highlight_unwanted_spaces
" Modified
" - ignore lines of purely white space (see "Keep the indent of blank lines" below)
" - ignore lines of spaces inside a phpDocumentor comment
"   /**
"    * For example:
"    * 
"    * ^ This line would not be highlighted even though it is indented
"    */
" n.b. See :help cterm-colors for the cterm colour list
highlight ExtraWhitespace ctermbg=DarkGreen guibg=DarkGreen
match ExtraWhiteSpace /\v((\s*\*\s+$)@!\S)@<=\s+$/

" Highlight all leading and trailing spaces/tabs
"highlight ExtraWhitespace ctermbg=DarkGrey guibg=#222222
"match ExtraWhiteSpace /\v(^\s+|\s+$)/

" These seem to make the cursor disappear when moving between lines quickly in
" insert mode, and are not 100% reliable anyway:
"au InsertEnter * match ExtraWhiteSpace /\S\@<=\s\+\%#\@<!$/
"au InsertLeave * match ExtraWhiteSpace /\S\@<=\s\+$/

" Much simpler but more annoying method of highlighting trailing spaces:
"set listchars=trail:·

"================================================================================
" Keep the indent of blank lines
"================================================================================

" http://vim.wikia.com/wiki/Prevent_autoindent_from_removing_indentation
" (Modified so that backspace works as expected when indenting with spaces
" i.e. it backspaces two spaces at a time)
inoremap <CR> <CR><Left><Right>
nnoremap o o<Left><Right>
nnoremap O O<Left><Right>

"================================================================================
" Indent/unindent shortcuts
"================================================================================
" Note: MOVED TO vimfiles/plugin/snipMate.vim so I can use <Tab> instead

" Visual mode indent, keeping highlight afterwards
"vnoremap <C-[> <gv
"vnoremap <C-]> >gv

" Visual mode indent, keeping highlight afterwards, and indenting blank lines also
"function! MyIndent()
"  " Explanation:
"  " :'<,'>s   Replace within visual selection
"  " ^         Replace start of line
"  " (.*\)\%V  Visual selection must start/end *after* the matched new line
"  "           i.e. exclude the last line of the selection *if* no characters are highlighted
"  "           but always include the first line of the selection
"  let spaces = (&expandtab ? repeat(" ", &sw) : "\t")
"  execute ":'<,'>s/^\\(.*\\)\\%V/" . spaces . "\\1"
"endfunction

" Note: Can't use <Tab> - it interferes with SnipMate, which uses <Tab> to jump to the next placeholder
" Note: Call indent, unindent first to convert leading tabs to spaces or vice-versa
"vnoremap <silent> <C-]> >gv<gv:<C-u>call MyIndent()<CR>
"vnoremap <C-[> <gv

"================================================================================
" Make ^Z undo smaller chunks at a time
"================================================================================

" http://vim.wikia.com/wiki/Modified_undo_behavior
inoremap <BS> <C-g>u<BS>
inoremap <Del> <C-g>u<Del>
inoremap <C-W> <C-g>u<C-W>

" Make paste a single action, rather than joining with text typed in
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

"================================================================================
" <Up>/<Down> navigates screen lines rather than file lines
"================================================================================

nnoremap k gk
nnoremap j gj
nnoremap <Up> gk
inoremap <Up> <C-O>gk
nnoremap <Down> gj
inoremap <Down> <C-O>gj
nnoremap <Home> g0
inoremap <Home> <C-O>g0
nnoremap <End> g$
inoremap <End> <C-O>g$
nnoremap <S-Up> gh<C-O>gk
inoremap <S-Up> <C-O>gh<C-O>gk
vnoremap <S-Up> gk
nnoremap <S-Down> gh<C-O>gj
inoremap <S-Down> <C-O>gh<C-O>gj
vnoremap <S-Down> gj

"================================================================================
" Some other keyboard shortcuts
"================================================================================

" ^D = Quit (prompts if not saved)
"noremap     <C-D>   :q<CR>
"inoremap    <C-D>   <C-O>:q<CR>

" w = Write
nmap        w       :w<CR>
nmap        W       :w<CR>

" q = Quit
nmap        q       :q<CR>
nmap        Q       :q<CR>

" e = Explore
nmap        e       :edit %:p:h<CR>
nmap        E       :edit %:p:h<CR>

" gf = Goto file (even if it doesn't exist yet)
" (Note: gF = Goto file & line)
nmap        gf      :e <cfile><CR>

" / = Search using normal RE not Vim's RE syntax that I can never remember!
nnoremap    /       /\v
vnoremap    /       /\v

" <F12> = Stop highlighting search results
nnoremap    <F12>   :nohlsearch<CR>
inoremap    <F12>   <C-O>:nohlsearch<CR>
vnoremap    <F12>   <C-O>:nohlsearch<CR>

" <F5> = Graphical undo
nnoremap    <F5>    :GundoToggle<CR>
inoremap    <F5>    <C-O>:nohlsearch<CR>
vnoremap    <F5>    <C-O>:nohlsearch<CR>

" Ctrl+D = Insert Date (DDD D MMM YYYY)
imap        <C-d>   <C-R>=strftime("%a %#d %b %Y")<CR>

" <Tab> = Jump between start and end braces
nnoremap    <tab>   %
vnoremap    <tab>   %

" ; instead of : for commands
nnoremap    ;       :

" Sort CSS properties alphabetically
nnoremap    <leader>S   ?{<CR>jV/^\s*\}?$<CR>k:sort<CR>:noh<CR>

"================================================================================
" Diff setup
"================================================================================

if has("win32")
    function! MyDiff()
        let opt = ""
        if &diffopt =~ "icase"
            let opt = opt . "-i "
        endif
        if &diffopt =~ "iwhite"
            let opt = opt . "-b "
        endif
        silent execute '!="'.$VIMRUNTIME.'\diff.exe" -a '.opt.'"'.v:fname_in.'" "'.v:fname_new.'" > "'.v:fname_out.'"'
    endfunction
    set diffexpr=MyDiff()
endif

"================================================================================
" Keep selection when indenting block-wise
"================================================================================
if version >= 700
    xnoremap < <gv
    xnoremap > >gv
endif

"================================================================================
" <Ctrl-Alt-Up/Down> swaps lines
"================================================================================

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

"================================================================================
" Auto-complete (X)HTML tags with Ctrl-Hyphen
"================================================================================

"au Filetype html,xml,xsl,php,smarty,javascript runtime closetag.vim
au Filetype * runtime closetag.vim
"au Filetype html,xml,xsl,php,smarty,javascript runtime xml.vim

"================================================================================
" Snippets
"================================================================================
let snips_html = "
    \<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n
    \<html lang=\"en-GB\" xml:lang=\"en-GB\" dir=\"ltr\" xmlns=\"http://www.w3.org/1999/xhtml\">\n
    \	<head>\n
    \		\n
    \		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n
    \		<meta http-equiv=\"Content-Language\" content=\"en-GB\" />\n
    \		\n
    \		<title>${1:Untitled Document}</title>\n
    \		\n
    \		<link rel=\"stylesheet\" href=\"/css/main.css\" type=\"text/css\" />\n
    \		\n
    \	</head>\n
    \	<body>\n
    \		\n
    \		${2}\n
    \		\n
    \	</body>\n
    \</html>"

"================================================================================
" Highlight long lines
"================================================================================
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

" :Long       Highlight after 80 characters
" :Long <N>   Highlight after <N> characters
command -nargs=? Long call HighlightLongLines(<f-args>)

" :NoLong     Remove highlighting
command NoLong call HighlightLongLines(0)

"================================================================================
" Learn to use HJKL keys instead of arrows!
"================================================================================
nnoremap <up>       <nop>
nnoremap <down>     <nop>
nnoremap <left>     <nop>
nnoremap <right>    <nop>
"inoremap <up>       <nop>
"inoremap <down>     <nop>
"inoremap <left>     <nop>
"inoremap <right>    <nop>
