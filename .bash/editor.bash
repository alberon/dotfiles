export VISUAL=vim
export EDITOR=vim

if $CYGWIN; then
    # Use the complete version of Vim on Windows instead of the cut down version
    # that's included with Git Bash
    for myvim in \
        "/c/Program Files \(x86\)/Vim/vim73/vim.exe" \
        "/c/Program Files/Vim/vim73/vim.exe";
    do
        if [ -f "$myvim" ]; then
            export VISUAL="$myvim"
            export EDITOR="$myvim"
            alias vim="\"$myvim\""
            alias vi="\"$myvim\""
            break
        fi
    done

    # And make gvim available too if possible
    for myvim in \
        "/c/Program Files (x86)/Vim/vim73/gvim.exe" \
        "/c/Program Files/Vim/vim73/gvim.exe";
    do
        if [ -f "$myvim" ]; then
            alias gvim="\"$myvim\""
            break
        fi
    done

    unset myvim
fi
