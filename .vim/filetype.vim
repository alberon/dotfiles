if exists("did_load_filetypes")
    finish
endif
augroup filetypedetect

    " AutoIt
    au BufNewFile,BufRead *.au3 setf autoit

    " Standard ML
    au BufNewFile,BufRead *.ml,*.sml setf sml

    " Java
    au BufNewFile,BufRead *.class setf class
    au BufNewFile,BufRead *.jad setf java

    " CSV
    au BufNewFile,BufRead *.csv setf csv

    " CakePHP
    au BufNewFile,BufRead *.thtml,*.ctp setf php

    " Drupal
    au BufNewFile,BufRead *.module,*.install setf php
    au BufNewFile,BufRead *.info setf dosini

    " Ruby
    au BufNewFile,BufRead *.rabl setf ruby

    " Text files
    au BufNewFile,BufRead *.txt setf txt

augroup END
