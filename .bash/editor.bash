export VISUAL=vim
export EDITOR=vim

if $CYGWIN; then
    # Use the complete version of Vim on Windows instead of the cut down version
    # that's included with Git Bash
    for vimpath in \
        "/c/Program Files \(x86\)/Vim/vim73" \
        "/c/Program Files/Vim/vim73";
    do
        if [ -f "$vimpath/vim.exe" ]; then
            PATH="$vimpath:$PATH"
            alias vi=vim.exe
            alias vim=vim.exe
            alias gvim=gvim.exe
            export VISUAL=vim.exe
            export EDITOR=vim.exe
            break
        fi
    done

    unset vimpath
fi
