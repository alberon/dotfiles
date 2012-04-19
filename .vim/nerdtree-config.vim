" Show hidden files *except* the known temp files, system files & VCS files
let NERDTreeShowHidden = 1

let NERDTreeIgnore = []
for suffix in split(&suffixes, ',')
    let NERDTreeIgnore += [ escape(suffix, '.~') . '$' ]
endfor
let NERDTreeIgnore += ['^.bzr$', '^.git$', '^.hg$', '^.svn$', '^\.$', '^\.\.$', '^Thumbs\.db$']

" Can't move to the right because it breaks the tabs plugin
"let NERDTreeWinPos = 'right'

" Increase tree width slightly
let NERDTreeWinSize = 38

" Focus file not tree when switching tabs
let g:nerdtree_tabs_focus_on_files = 1

" Change working directory to the root automatically
let g:NERDTreeChDirMode = 2
