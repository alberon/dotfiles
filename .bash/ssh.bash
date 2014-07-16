alias sshstop='ssh -O stop'

if $WINDOWS; then
    ssh() {
        touch ~/tmp/ssh-config-windows
        chmod 700 ~/tmp/ssh-config-windows
        command grep -v 'ControlPersist\|ControlPath' ~/.ssh/config > ~/tmp/ssh-config-windows
        command ssh -F ~/tmp/ssh-config-windows "$@"
    }
fi
