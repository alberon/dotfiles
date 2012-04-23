" Show hidden files *except* the known temp files, system files & VCS files
let NERDTreeShowHidden = 1

let NERDTreeIgnore = []
for suffix in split(&suffixes, ',')
    let NERDTreeIgnore += [ escape(suffix, '.~') . '$' ]
endfor
let NERDTreeIgnore += ['^.bzr$', '^.git$', '^.hg$', '^.svn$', '^\.$', '^\.\.$', '^Thumbs\.db$']

" Position on the right
"let NERDTreeWinPos = 'right'

" Increase tree width slightly
let NERDTreeWinSize = 38

" Change working directory to the root automatically
let g:NERDTreeChDirMode = 2

" Don't use for browsing directories because it doesn't work properly when the
" working directory is a different drive
let g:NERDTreeHijackNetrw = 0

" Open automatically, except when using CLI, or when editing files in WinSCP
" (because WinSCP doesn't use a sensible directory structure - every file gets
" a separate temp directory)
if has('gui') && v:servername != "WINSCP"
    autocmd VimEnter * NERDTree | wincmd p
endif
