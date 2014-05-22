# tmux attach
alias tm='tmux attach'

# ssh + tmux
sshtm() {
    ssh -t "$@" "tmux attach"
}
