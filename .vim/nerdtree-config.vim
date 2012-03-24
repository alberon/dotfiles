let NERDTreeIgnore = []
for suffix in split(&suffixes, ',')
    let NERDTreeIgnore += [ escape(suffix, '.~') . '$' ]
endfor
let NERDTreeIgnore += ['^.bzr$', '^.git$', '^.hg$', '^.svn$', '^\.$', '^\.\.$', '^Thumbs\.db$']

let NERDTreeShowHidden = 1
"let NERDTreeWinPos = 'right'
let NERDTreeWinSize = 38
