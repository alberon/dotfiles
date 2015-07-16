alias v=vagrant

vagrant() {
    # No parameters
    if [ $# -eq 0 ]; then
        command vagrant
        echo
        echo "Shortcuts:"
        echo "     u       up"
        echo "     p       provision"
        echo "     s       ssh"
        echo "     st      status"
        echo "     d       suspend (down)"
        echo "     hosts   update /etc/hosts (hostmanager)"
        return
    fi

    # Parse the first parameter for shortcuts - because I'm lazy!
    cmd="$1"
    shift

    case "$cmd" in
        u)     cmd=up          ;;
        p)     cmd=provision   ;;
        st)    cmd=status      ;;
        d)     cmd=suspend     ;;
        down)  cmd=suspend     ;;
        stop)  cmd=halt        ;;
        hosts) cmd=hostmanager ;;
    esac

    # Special case for the 's' command
    if [ "$cmd" = "s" ]; then
        if [ $# -gt 0 ]; then
            # 'v s <cmd>' => Treat the extra parameters as a command
            command vagrant ssh -c "$*"
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
