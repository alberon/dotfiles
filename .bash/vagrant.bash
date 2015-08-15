alias v=vagrant

vagrant() {
    # No parameters
    if [ $# -eq 0 ]; then
        command vagrant

        # 1 = Help message displayed (or maybe other errors?)
        # 127 = Command not found
        if [ $? -eq 1 ]; then
            echo "Shortcuts:"
            echo "     d        suspend (down)"
            echo "     hosts    update /etc/hosts (hostmanager)"
            echo "     p        provision"
            echo "     s        ssh"
            echo "     st       status"
            echo "     u        up"
        fi

        return
    fi

    # Parse the first parameter for shortcuts - because I'm lazy!
    cmd="$1"
    shift

    case "$cmd" in
        d)     cmd=suspend       ;;
        down)  cmd=suspend       ;;
        gs)    cmd=global-status ;;
        hosts) cmd=hostmanager   ;;
        p)     cmd=provision     ;;
        st)    cmd=status        ;;
        stop)  cmd=halt          ;;
        u)     cmd=up            ;;
    esac

    # Special case for the 's' command
    if [ "$cmd" = "s" ]; then
        if [ $# -gt 0 ]; then
            # 'v s <cmd>' => Treat the extra parameters as a command
            command vagrant ssh -c "cd /vagrant; $*"
            return
        elif [ -z "$TMUX" ]; then
            # Not running tmux - Run tmux inside Vagrant (if available)
            command vagrant ssh -- -t 'which tmux >/dev/null 2>&1 && { tmux attach || tmux new -s default; } || bash -l'
        elif $CYGWIN; then
            # We're running tmux already - on Cygwin
            # For some reason Cygwin -> tmux -> vagrant (ruby) -> ssh is *really* slow
            # But if we skip ruby it's fine!
            # Note: The Vagrant setup may still be slow... So I don't use tmux in Cygwin much
            (umask 077 && command vagrant ssh-config > /tmp/vagrant-ssh-config)
            ssh -F /tmp/vagrant-ssh-config default
        else
            # We're running tmux on another platform - just connect as normal
            command vagrant ssh
        fi
        return
    fi

    # Other commands
    command vagrant "$cmd" "$@"
}

# Workaround for Vagrant bug on Cygwin
# https://github.com/mitchellh/vagrant/issues/6026
if $CYGWIN; then
    export VAGRANT_DETECTED_OS=cygwin
fi
