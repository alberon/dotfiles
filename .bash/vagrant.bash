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
        s)     cmd=ssh         ;;
        st)    cmd=status      ;;
        d)     cmd=suspend     ;;
        down)  cmd=suspend     ;;
        stop)  cmd=halt        ;;
        hosts) cmd=hostmanager ;;
    esac

    # Special case for the 'ssh' command with no parameters
    if [ "$cmd" = "ssh" -a $# -eq 0 ]; then
        if [ -z "$TMUX" ]; then
            # Run tmux inside Vagrant (if available)
            command vagrant ssh -- -t 'which tmux >/dev/null 2>&1 && { tmux attach || tmux new -s default; } || bash -l'
        elif $CYGWIN; then
            # We're running tmux already
            # For some reason Cygwin -> tmux -> vagrant (ruby) -> ssh is *really* slow
            # But if we skip ruby it's fine!
            (umask 077 && command vagrant ssh-config > /tmp/vagrant-ssh-config)
            ssh -F /tmp/vagrant-ssh-config default
        else
            # Run as normal
            command vagrant ssh
        fi
        return
    fi

    # Other commands
    command vagrant "$cmd" "$@"
}
