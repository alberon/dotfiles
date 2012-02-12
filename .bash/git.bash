# g = git
alias g='git'

# Auto-complete git commands for git aliases (g, cfg, hub)
if type _git >/dev/null 2>&1; then
    for cmd in g cfg hub; do
        complete -o bashdefault -o default -o nospace -F _git $cmd 2>/dev/null ||
        complete -o default -o nospace -F _git $cmd
    done
fi
