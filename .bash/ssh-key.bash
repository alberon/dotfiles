file=

if ! $MAC; then
    if [ -n "$HOME/.ssh/id_rsa" ]; then
        file="$HOME/.ssh/id_rsa"
    elif [ -f "$HOME/.ssh/id_dsa" ]; then
        file="$HOME/.ssh/id_dsa"
    fi
fi

if [ -f "$file" ]; then
    # Exit if a key is already loaded
    if ! ssh-add -l >/dev/null; then

        # Make it clear which server is asking for the password!
        echo
        echo -e "\033[31;1mYou are connected to $HOSTNAME.\033[33;1m"

        # Set titlebar for KeePass
        case "$TERM" in
            xterm*)
                echo -ne "\033]2;Enter SSH Key Password\a"
                ;;
        esac

        # Trap Ctrl-C
        trapped=0
        trap 'trapped=1' SIGINT

        # Prompt for password
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