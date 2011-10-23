let NERDTreeIgnore = []
for suffix in split(&suffixes, ',')
    let NERDTreeIgnore += [ escape(suffix, '.~') . '$' ]
endfor

let NERDTreeIgnore += ['^.bzr$', '^.hg$', '^.svn$', '^\.$', '^\.\.$', '^Thumbs\.db$']
let NERDTreeShowHidden = 1
let NERDTreeWinPos = 'right'
let NERDTreeWinSize = 50
let NERDTreeShowBookmarks = 1
let NERDTreeStopInsert = 1
