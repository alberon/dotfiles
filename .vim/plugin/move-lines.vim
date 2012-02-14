" <Ctrl-Alt-Up/Down> swaps lines
" http://vim.wikia.com/wiki/Transposing
function! <SID>MoveLineUp()
    call <SID>MoveLineOrVisualUp(".", "")
endfunction

function! <SID>MoveLineDown()
    call <SID>MoveLineOrVisualDown(".", "")
endfunction

function! <SID>MoveVisualUp()
    call <SID>MoveLineOrVisualUp("'<", "'<,'>")
    normal gv
endfunction

function! <SID>MoveVisualDown()
    call <SID>MoveLineOrVisualDown("'>", "'<,'>")
    normal gv
endfunction

function! <SID>MoveLineOrVisualUp(line_getter, range)
    let l_num = line(a:line_getter)
    if l_num - v:count1 - 1 < 0
        let move_arg = "0"
    else
        let move_arg = a:line_getter." -".(v:count1 + 1)
    endif
    call <SID>MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
endfunction

function! <SID>MoveLineOrVisualDown(line_getter, range)
    let l_num = line(a:line_getter)
    if l_num + v:count1 > line("$")
        let move_arg = "$"
    else
        let move_arg = a:line_getter." +".v:count1
    endif
    call <SID>MoveLineOrVisualUpOrDown(a:range."move ".move_arg)
endfunction

function! <SID>MoveLineOrVisualUpOrDown(move_arg)
    let col_num = virtcol(".")
    execute "silent! ".a:move_arg
    execute "normal! ".col_num."|"
endfunction

nnoremap <silent> <C-A-Up> :<C-u>call <SID>MoveLineUp()<CR>
nnoremap <silent> <C-A-Down> :<C-u>call <SID>MoveLineDown()<CR>
inoremap <silent> <C-A-Up> <C-o>:<C-u>call <SID>MoveLineUp()<CR>
inoremap <silent> <C-A-Down> <C-o>:<C-u>call <SID>MoveLineDown()<CR>
vnoremap <silent> <C-A-Up> :<C-u>call <SID>MoveVisualUp()<CR>
vnoremap <silent> <C-A-Down> :<C-u>call <SID>MoveVisualDown()<CR>
