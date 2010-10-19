" Maximize window automatically
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

"autocmd GUIEnter * simalt ~x
"autocmd GUIEnter * winpos -1270 10 | set lines=71 columns=155

" Set titlebar to full path to current file
" Except when it's opened from WinSCP strip the temp directory prefix off
" TODO: Make this work when viewing directories
autocmd BufWinEnter * let &titlestring=substitute(expand("%:p"), '^.*\\temp\\scp[0-9]\+\\', '', 'i')

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

" Quick-edit settings
an 20.422  &Edit.-SEP2_5-      <Nop>
an <silent> 20.423  &Edit.Edit\ &vimrc  :if has("win32")<CR>:edit $VIM/.vimrc<CR>:else<CR>:edit $HOME/.vimrc<CR>:endif<CR>
an <silent> 20.424   &Edit.Edit\ gvi&mrc :if has("win32")<CR>:edit $VIM/.gvimrc<CR>:else<CR>:edit $HOME/.gvimrc<CR>:endif<CR>

" Example QuickText Menu
"an 25.1 &QuickText.&PHPDoc\ Header :insert<CR>/**<CR> * @author Dave Miller<CR> */<CR>.<CR>

" Diff Patch
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

" Open URL
" http://vim.wikia.com/wiki/Open_a_web-browser_with_the_URL_in_the_current_line
let $PATH = $PATH . ';c:\Program Files (x86)\Mozilla Firefox;c:\Program Files\Mozilla Firefox'
function! Browser ()
  
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

