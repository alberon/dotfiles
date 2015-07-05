# g = git
alias g='git'

# 'git' with no parameters loads interactive REPL
git() {
    if [ $# -gt 0 ]; then
        command git "$@"
    else
        command git status &&
        command git repl
    fi
}

# Auto-complete git commands for git aliases (g, cfg)
if type _git >/dev/null 2>&1; then
    for cmd in g cfg; do
        complete -o bashdefault -o default -o nospace -F _git $cmd 2>/dev/null ||
        complete -o default -o nospace -F _git $cmd
    done
fi

# cd to repo root
cg() {
    cd "$(git rev-parse --show-toplevel)"
}

# Workaround for Git hanging when using Composer
export GIT_SSH='ssh-noninteractive'
