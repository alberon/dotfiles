" There's no option for Buffer Explorer not to set these mappings, so we have
" to remove them afterwards, otherwise <Leader>b on its own waits for another
" character which makes it slow to reacta
silent! nunmap <Leader>be
silent! nunmap <Leader>bs
silent! nunmap <Leader>bv
