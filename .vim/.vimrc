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

" If the file is already open, switch to it
" Removed Sat 14 May 2016 because it conflicts in Vim 7.4 (Ubunti 16.04) and
" I'm not sure why - but I don't use Vim enough to spend any longer fixing it
"if !exists("*EditExisting")
"    runtime macros/editexisting.vim
"endif

" Change out of the c:\windows\system32 directory because NERDtree seems to
" fail to load (or loads *really* slowly) in that directory
if getcwd() == $windir . "\\system32"
    cd $HOME
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
function! PreserveCursor(command)
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

" File type detection
filetype plugin on

" Always use Unix-format new lines for new files
au BufNewFile * if !&readonly && &modifiable | set fileformat=unix | endif

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

" Automatically cd to the directory that the current file is in
" This first option is built in but doesn't quite work as you'd expect - see
" http://stackoverflow.com/questions/164847/what-is-in-your-vimrc/652632#652632
" Added silent! to prevent error messages if the file & directory has been deleted
"set autochdir
" Removed 2012-04-19 because I want paths relative to the project root
"autocmd BufEnter * execute "silent! chdir ".escape(expand("%:p:h"), ' ')

" Auto-complete (X)HTML tags with Ctrl-Hyphen
au Filetype * runtime closetag.vim

" Use Sparkup to generate HTML quickly (Ctrl-E)
au Filetype * runtime sparkup.vim

" FuzzyFinder - if search begins with a space do a recursive search
if v:version >= 700
    let g:fuf_abbrevMap = {
        \   "^ " : [ "**/", ],
        \}
endif

" Sort CSS properties alphabetically
command! SortCSS silent! call PreserveCursor("?{?+1,/}/-1sort")

" Sort .snippets files alphabetically
if v:version >= 700
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

    command! SortSnippets silent! call PreserveCursor("call <SID>SortSnippets()")
endif

" Load local config
let include = $HOME . "/.vimrc_local"

if filereadable(include)
    exe "source " . include
endif


"===============================================================================
" Finish the autocommands group
augroup END
