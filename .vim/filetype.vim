if exists('did_load_filetypes')
    finish
endif
augroup filetypedetect

    " A new file with no extension in one of the directories where shell
    " scripts commonly live
    autocmd BufNewFile */.bin/*,*/bin/*,*/scripts/*
    \   if expand('%:p') =~# '\v/[^.]+$'
    \|      setfiletype sh
    \|  endif

augroup END
