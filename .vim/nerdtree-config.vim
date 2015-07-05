" Show hidden files *except* the known temp files, system files & VCS files
let NERDTreeShowHidden = 1

let NERDTreeIgnore = []
for suffix in split(&suffixes, ',')
    let NERDTreeIgnore += [ escape(suffix, '.~') . '$' ]
endfor
let NERDTreeIgnore += ['^\.bundle$', '^\.bzr$', '^\.git$', '^\.hg$', '^\.sass-cache$', '^\.svn$', '^\.$', '^\.\.$', '^Thumbs\.db$']

" Position on the right
"let NERDTreeWinPos = 'right'

" Increase tree width slightly
let NERDTreeWinSize = 38

" Change working directory to the root automatically
let g:NERDTreeChDirMode = 2

" Don't use for browsing directories because it doesn't work properly when the
" working directory is a different drive
let g:NERDTreeHijackNetrw = 0

" Change help key from ? to F1 so that ? can be used for searching
let g:NERDTreeMapHelp = '<F1>'

" Open automatically, except when using CLI, or when editing files in WinSCP
" (because WinSCP doesn't use a sensible directory structure - every file gets
" a separate temp directory)
" Removed because these days I normally use Vim only for quick edits and I use
" Sublime Text for projects -Aug 2013
"if has('gui_running') && v:servername != "WINSCP" && !exists("g:nonerdtree")
"    autocmd VimEnter * NERDTree | wincmd p
"endif
