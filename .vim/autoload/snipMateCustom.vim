fun! snipMateCustom#AutoClassName()
  let filename = expand('%:p')
  if filename == ''
    return 'ClassName'
  endif
  let filename = substitute(filename, '\\', '/', 'g')
  if match(filename, '/classes/') > -1
    let filename = substitute(filename, '^.*/classes/', '', '')
    let filename = substitute(filename, '/', '_', 'g')
    let filename = substitute(filename, '\.php$', '', '')
  else
    let filename = expand('%:t:r')
  endif
  return filename
endf

