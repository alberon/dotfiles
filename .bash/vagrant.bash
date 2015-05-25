alias v=vagrant

vagrant() {
    if [ $# -eq 1 -a "$1" = "ssh" ]; then
        # Default to running tmux inside vagrant ssh
        command vagrant ssh -- -t 'which tmux >/dev/null 2>&1 && { tmux attach || tmux new -s default; } || bash -l'
    else
        command vagrant "$@"
    fi
}
