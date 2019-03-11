agent=
file=

if ! $MAC; then
    if [ -n "$HOME/.ssh/id_rsa" ]; then
        file="$HOME/.ssh/id_rsa"
    elif [ -f "$HOME/.ssh/id_dsa" ]; then
        file="$HOME/.ssh/id_dsa"
    fi
fi

if $WINDOWS; then
    # Use Pageant for SSH keys so I don't have to re-enter the SSH key password
    # https://github.com/cuviper/ssh-pageant
    case "$(uname -a)" in
        CYGWIN_*i686*)
            agent="ssh-pageant-1.4-prebuilt-cygwin32"
            ;;
        CYGWIN_*x86_64*)
            agent="ssh-pageant-1.4-prebuilt-cygwin64"
            ;;
    esac
fi

if [ -n "$agent" ]; then

    # ssh-pageant
    eval $($HOME/opt/$agent/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")

elif [ -f "$file" ]; then

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
# Currently not working on Mac
# And it stops working on MSys when you run "reload"
# But I don't have tmux working on those platforms anyway!
if ! $MAC && ! $MSYSGIT; then

    # First we make sure there's a valid socket connecting us to the agent and
    # it's not already pointing to the symlink, and there's no existing
    # working symlink:
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
