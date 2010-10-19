" Remove the default vimfiles path
set runtimepath-=$VIM/vimfiles
set runtimepath-=$VIM/vimfiles/after

" Change $VIM so .gvimrc is read automatically
let $VIM = "d:/Vim config"

" Add the custom runtime path
set runtimepath^=$VIM/.vim
set runtimepath+=$VIM/.vim/after

" Load the real .vimrc
source $VIM/.vimrc

" Override the backup directory
"set backupdir=h:/Temp/Vim//
"set directory=h:/Temp/Vim//

