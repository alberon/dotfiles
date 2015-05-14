if $WINDOWS; then

    # Fix errors caused by Msysgit using an old version of OpenSSH
    # Now removed in favour of using PuTTY
    # ssh() {
    #     touch ~/tmp/ssh-config-windows
    #     chmod 700 ~/tmp/ssh-config-windows
    #     command grep -v 'ControlPersist\|ControlPath' ~/.ssh/config > ~/tmp/ssh-config-windows
    #     command ssh -F ~/tmp/ssh-config-windows "$@"
    # }

    # Use PuTTY instead of OpenSSH so I don't have to re-enter the SSH key password
    if [ -f /c/Program\ Files/PuTTY/plink.exe ]; then

        export GIT_SSH=/c/Program\ Files/PuTTY/plink.exe
        alias ssh="/c/Program\ Files/PuTTY/plink.exe"

    elif [ -f /c/Program\ Files\ \(x86\)/PuTTY/plink.exe ]; then

        export GIT_SSH=/c/Program\ Files\ \(x86\)/PuTTY/plink.exe
        alias ssh="/c/Program\ Files\ \(x86\)/PuTTY/plink.exe"

    fi

    # Clear the MOTD (at this point it's already been shown, but gets rid of it for the future)
    if [ -w /etc/motd ]; then
        > /etc/motd
    fi

fi
