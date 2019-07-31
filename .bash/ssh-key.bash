agent=
file=

# Check for local keys
# macOS loads them automatically
if ! $MAC; then
    if [ -n "$HOME/.ssh/id_rsa" ]; then
        file="$HOME/.ssh/id_rsa"
    elif [ -f "$HOME/.ssh/id_dsa" ]; then
        file="$HOME/.ssh/id_dsa"
    fi
fi

# Bridge to Pageant on Windows so we can share keys
if $WSL; then

    # Windows System for Linux
    # https://github.com/benpye/wsl-ssh-pageant
    if ! pgrep -l wsl-ssh-pageant >/dev/null; then
        # WSL won't run a Windows app that's inside the Linux filesystem, so copy it to a temp directory first
        # This sometimes fails even when pgrep doesn't think it's running, but that's generally OK
        rm -f "$WIN_TEMP_UNIX/wsl-ssh-pageant.exe" "$WIN_TEMP_UNIX/wsl-ssh-pageant.sock" 2>/dev/null && \
        cp $HOME/opt/wsl-ssh-pageant/wsl-ssh-pageant-amd64.exe "$WIN_TEMP_UNIX/wsl-ssh-pageant.exe"

        "$WIN_TEMP_UNIX/wsl-ssh-pageant.exe" --wsl "$WIN_TEMP/wsl-ssh-pageant.sock" 2>/dev/null &
    fi

    export SSH_AUTH_SOCK="$WIN_TEMP_UNIX/wsl-ssh-pageant.sock"

elif $CYGWIN; then

    # Cygwin
    # https://github.com/cuviper/ssh-pageant
    case "$(uname -a)" in
        CYGWIN_*i686*)
            eval $($HOME/opt/ssh-pageant-1.4-prebuilt-cygwin32/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")
            ;;
        CYGWIN_*x86_64*)
            eval $($HOME/opt/ssh-pageant-1.4-prebuilt-cygwin64/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")
            ;;
    esac

fi

# Local key file / agent
if [ -f "$file" ]; then

    # ssh-agent
    # Make sure the agent is running
    if [ -z "$SSH_AGENT_PID" ] || (! kill -0 "$SSH_AGENT_PID" 2>/dev/null); then

        UNAME="$(uname)"

        # Try the stored settings instead
        if [ -f ~/.ssh/environment-$HOSTNAME-$UNAME ]; then
            source ~/.ssh/environment-$HOSTNAME-$UNAME
        fi

        if [ -z "$SSH_AGENT_PID" ] || (! kill -0 "$SSH_AGENT_PID" 2>/dev/null); then
            chmod 700 ~/.ssh
            ssh-agent | head -2 > ~/.ssh/environment-$HOSTNAME-$UNAME
            source ~/.ssh/environment-$HOSTNAME-$UNAME
        fi

    fi

    # Ask for password
    if $HAS_TERMINAL && ! ssh-add -l >/dev/null; then

        # Make it clear which server is asking for the password!
        # echo
        # echo -e "\033[31;1mYou are connected to $HOSTNAME.\033[33;1m"

        # Set titlebar for KeePass
        case "$TERM" in
            xterm*|cygwin)
                echo -ne "\033]2;Enter SSH Key Password\a"
                ;;
        esac

        # Trap Ctrl-C
        trapped=0
        trap 'trapped=1' SIGINT

        # Prompt for password
        chmod 700 ~/.ssh
        chmod 600 "$file"
        ssh-add "$file"

        if [ $? -eq 0 -a $trapped -eq 0 ]; then
            echo -e "\033[32;1mSSH keys are now unlocked.\033[0m"
            KeyStatus=$KeyStatusUnlocked
            return 0
        else
            echo -e "\033[30;1mCancelled. SSH keys are still locked.\033[0m"
            KeyStatus=$KeyStatusLocked
        fi

        # Reset trap
        trap SIGINT
        trapped=

    fi
fi

# Workaround for losing SSH agent connection when reconnecting tmux: update a
# symlink to the socket each time we reconnect and use that as the socket in
# every session.
# Currently not working on Mac, but I don't use it
# And it stops working on MSys when you run "reload", but I don't use that either
# And it doesn't work but also isn't necessary on WSL
if ! $MAC && ! $MSYSGIT && ! $WSL; then

    # First we make sure there's a valid socket connecting us to the agent and
    # it's not already pointing to the symlink, and there's no existing
    # working symlink.
    link="$HOME/.ssh/ssh_auth_sock"
    if [ "$SSH_AUTH_SOCK" != "$link" -a -S "$SSH_AUTH_SOCK" -a ! -S "$link" ]; then
        # We also check if the agent has any keys loaded - PuTTY will still open an
        # agent connection even if we used password authentication
        if ssh-add -l >/dev/null 2>&1; then
            ln -nsf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
        fi
    fi

    # Now that's done we can use the symlink for every session
    export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"

fi
