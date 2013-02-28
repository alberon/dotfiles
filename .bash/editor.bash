export EDITOR=vim
export GEDITOR=vim

if $MAC; then

    # Only if MacVim is installed, and using a local terminal not SSH
    if [ -z "$SSH_CLIENT" ] && which mvim >/dev/null; then
        alias gvim=mvim
        export GEDITOR=mvim
    fi

elif $CYGWIN; then

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
            export EDITOR=vim.exe
            export GEDITOR=gvim.exe
            break
        fi
    done

    unset vimpath

fi

export VISUAL=$EDITOR
