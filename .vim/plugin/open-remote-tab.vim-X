" This is based on macros/editexisting.vim from the standard Vim scripts,
" but modified to use tabs. It could do with some simplification, but it
" works anyway! -DJM

if v:version < 700
    finish
endif

" Only do this with gVim not console Vim, otherwise it breaks Git commit
" messages by exiting too early
if ! has("gui")
    finish
endif

" Function that finds the Vim instance that is editing "filename" and brings
" it to the foreground.
func! s:EditElsewhere(filename)
  let fname_esc = substitute(a:filename, "'", "''", "g")

  let servers = serverlist()
  while servers != ''
    " Get next server name in "servername"; remove it from "servers".
    let i = match(servers, "\n")
    if i == -1
      let servername = servers
      let servers = ''
    else
      let servername = strpart(servers, 0, i)
      let servers = strpart(servers, i + 1)
    endif

    " Skip ourselves.
    if servername ==? v:servername
      continue
    endif

    " Check if this server is editing our file.
    if remote_expr(servername, "bufloaded('" . fname_esc . "')")
      " Yes, bring it to the foreground.
      if has("win32")
        call remote_foreground(servername)
      endif
      call remote_expr(servername, "foreground()")

      if remote_expr(servername, "exists('*EditExisting')")
        " Make sure the file is visible in a window (not hidden).
        " If v:swapcommand exists and is set, send it to the server.
        if exists("v:swapcommand")
          let c = substitute(v:swapcommand, "'", "''", "g")
          call remote_expr(servername, "EditExisting('" . fname_esc . "', '" . c . "')")
        else
          call remote_expr(servername, "EditExisting('" . fname_esc . "', '')")
        endif
      endif

      if !(has('vim_starting') && has('gui_running') && has('gui_win32'))
        " Tell the user what is happening.  Not when the GUI is starting
        " though, it would result in a message box.
        echomsg "File is being edited by " . servername
        sleep 2
      endif
      return 'q'
    endif
  endwhile
  return ''
endfunc

" When the plugin is loaded and there is one file name argument: Find another
" Vim server that is editing this file right now.
if argc() == 1 && !&modified
  if s:EditElsewhere(expand("%:p")) == 'q'
    quit
  endif
endif

" Setup for handling the situation that an existing swap file is found.
try
  au! SwapExists * let v:swapchoice = s:EditElsewhere(expand("<afile>:p"))
catch
  " Without SwapExists we don't do anything for ":edit" commands
endtry

" Function used on the server to make the file visible and possibly execute a
" command.
func! EditExisting(fname, command)
  " Get the window number of the file in the current tab page.
  let winnr = bufwinnr(a:fname)
  if winnr <= 0
    " Not found, look in other tab pages.
    let bufnr = bufnr(a:fname)
    for i in range(tabpagenr('$'))
      if index(tabpagebuflist(i + 1), bufnr) >= 0
        " Make this tab page the current one and find the window number.
        exe 'tabnext ' . (i + 1)
        let winnr = bufwinnr(a:fname)
        break;
      endif
    endfor
  endif

  if winnr > 0
    exe winnr . "wincmd w"
  elseif exists('*fnameescape')
    exe "tabedit " . fnameescape(a:fname)
  else
    exe "tabedit " . escape(a:fname, " \t\n*?[{`$\\%#'\"|!<")
  endif

  if a:command != ''
    exe "normal " . a:command
  endif

  redraw
endfunc

" Function that finds the Vim instance that is editing "filename" and brings
" it to the foreground.
func! s:EditElsewhereTab(filename)
    let fname_esc = substitute(a:filename, "'", "''", "g")

    let servers = serverlist()
    while servers != ''
        " Get next server name in "servername"; remove it from "servers".
        let i = match(servers, "\n")
        if i == -1
            let servername = servers
            let servers = ''
        else
            let servername = strpart(servers, 0, i)
            let servers = strpart(servers, i + 1)
        endif

        " Skip ourselves.
        if servername ==? v:servername
            continue
        endif

        " Bring the remote window to the foreground.
        if has("win32")
            call remote_foreground(servername)
        endif
        call remote_expr(servername, "foreground()")

        if remote_expr(servername, "exists('*OpenTab')")
            call remote_expr(servername, "OpenTab('" . fname_esc . "')")
            return 'q'
        endif

    endwhile
    return ''
endfunc

" When the plugin is loaded and there is one file name argument: Find another
" Vim server that is editing this file right now.
if argc() == 1 && !&modified
    if s:EditElsewhereTab(expand("%:p")) == 'q'
        quit
    endif
endif

" Function used on the server to make the file visible and possibly execute a
" command.
func! OpenTab(fname)
    if exists('*fnameescape')
        exe "tabedit " . fnameescape(a:fname)
    else
        exe "tabedit " . escape(a:fname, " \t\n*?[{`$\\%#'\"|!<")
    endif

    redraw
endfunc
