" NERDTree config has to be in a separate file to avoid causing errors in
" older versions of Vim due to the array syntax
if version >= 700
    runtime nerdtree-config.vim
endif
