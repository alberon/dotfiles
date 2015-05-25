alias v=vagrant

vagrant() {
    if [ $# -eq 1 -a "$1" = "ssh" ]; then
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
            command vagrant "$@"
        fi
    else
        command vagrant "$@"
    fi
}
