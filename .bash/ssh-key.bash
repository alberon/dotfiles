if [ -f ~/.ssh/id_rsa ]; then
    # Exit if a key is already loaded
    if ! ssh-add -l >/dev/null; then

        # Set titlebar for KeePass
        case "$TERM" in
            xterm*)
                echo -ne "\e]2;Enter SSH Key Password\a"
                ;;
        esac

        ssh-add ~/.ssh/id_rsa

    fi
fi
