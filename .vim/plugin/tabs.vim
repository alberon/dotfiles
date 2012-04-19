" Show tab bar always
"if v:version >= 700
"    set showtabline=2
"endif

" Ctrl-T to open a new tab
map <C-t> :tabnew<cr>
nmap <C-t> :tabnew<cr>
imap <C-t> <ESC>:tabnew<cr>

" Cycle through tabs with Ctrl-Tab as well as Ctrl-PageDn/Up
" (Removed because Ctrl-Tab is used to cycle windows not tabs now)
"map <C-Tab> :tabnext<CR>
"map <C-S-Tab> :tabprev<CR>
"inoremap <C-Tab> <C-O>:tabnext<CR>
"inoremap <C-S-Tab> <C-O>:tabprev<CR>

" Move tabs around with Alt-PageDn/Up
function! <SID>TabLeft()
   let tab_number = tabpagenr() - 1
   if tab_number == 0
      execute "tabm" tabpagenr('$') - 1
   else
      execute "tabm" tab_number - 1
   endif
endfunction

function! <SID>TabRight()
   let tab_number = tabpagenr() - 1
   let last_tab_number = tabpagenr('$') - 1
   if tab_number == last_tab_number
      execute "tabm" 0
   else
      execute "tabm" tab_number + 1
   endif
endfunction

map <silent> <A-PageUp> :call PreserveCursor("execute <SID>TabLeft()")<CR>
map <silent> <A-PageDown> :call PreserveCursor("execute <SID>TabRight()")<CR>

" Set up tab labels with tab number, buffer name, number of windows
function! GuiTabLabel()
    let label = ''
    let bufnrlist = tabpagebuflist(v:lnum)

    " Tab number
    let label .= v:lnum.': '

    " Buffer name
    let name = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
    if name != ''
        let name = fnamemodify(name,":t")
    elseif &buftype == 'quickfix'
        let name = '[Quickfix List]'
    else
        let name = '[No Name]'
    endif
    let label .= name

    " Append the number of windows in the tab page
    let wincount = tabpagewinnr(v:lnum, '$')
    if wincount > 1
        let label .= ' [' . wincount . ']'
    endif

    " Add '+' if one of the buffers in the tab page is modified
    " Wrapped in execute for Vim 6.3 support
    execute
        \ 'for bufnr in bufnrlist'
        \ '|  if getbufvar(bufnr, "&modified")'
        \ '|      let label .= "+"'
        \ '|      break'
        \ '|  endif'
        \ '|endfor'

    return label
endfunction

if v:version >= 700
    set guitablabel=%{GuiTabLabel()}
endif
