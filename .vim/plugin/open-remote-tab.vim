if v:version < 700
    finish
endif

" Only do this with gVim not console Vim, otherwise it breaks Git commit
" messages by exiting too early
if ! has("gui")
    finish
endif

" Switch to existing tab if available
" Only load if it's not already loaded - otherwise we get an error about
" the function already being defined (because it doesn't use "func!")
if !exists("*EditExisting")
    runtime macros/editexisting.vim
endif

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
