let NERDTreeIgnore = []
for suffix in split(&suffixes, ',')
    let NERDTreeIgnore += [ escape(suffix, '.~') . '$' ]
endfor

let NERDTreeIgnore += ['^.hg$', '^\.$', '^\.\.$', '^Thumbs\.db$']
let NERDTreeShowHidden = 1
let NERDTreeWinPos = 'right'
let NERDTreeWinSize = 40
let NERDTreeMapOpenExpl = '<Leader>e'
