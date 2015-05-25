export EDITOR=vim
export GEDITOR=vim

if $MAC; then

    # Only if using a local terminal not SSH
    if [ -z "$SSH_CLIENT" ]; then
        if [ -f /Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl ]; then

            # Sublime Text 2
            export EDITOR='subl -w'
            export GEDITOR=subl

        elif mvim --version >/dev/null 2>&1; then

            # MacVim
            # Note: Can't use `which mvim` above because the mvim script exists
            # whether or not the actual MacVim.app exists - so we have to run
            # the script to determine whether it returns an error or not
            alias gvim=mvim
            export EDITOR='mvim --cmd "let g:nonerdtree = 1" -f'
            export GEDITOR=mvim

        fi
    fi

elif $MSYSGIT; then

    # Use the complete version of Vim on Windows instead of the cut down version
    # that's included with Git Bash
    for vimpath in \
        "/c/Program Files (x86)/Vim/vim74" \
        "/c/Program Files/Vim/vim74" \
        "/c/Program Files (x86)/Vim/vim73" \
        "/c/Program Files/Vim/vim73";
    do
        if [ -f "$vimpath/vim.exe" ]; then
            PATH="$vimpath:$PATH"
            alias vi=vim.exe
            alias vim=vim.exe
            alias gvim=gvim.exe
            export EDITOR=vim.exe
            export GEDITOR=vim.exe
            break
        fi
    done

    unset vimpath

fi

export VISUAL=$EDITOR
