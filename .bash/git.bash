# g = git
alias g='git'

# Make sure hub username is configured
# https://github.com/defunkt/hub/issues/225
init_hub() {
    if [ ! -f ~/.config/hub ]; then
        if [ ! -d ~/.config ]; then
            mkdir ~/.config
        fi

        cat >~/.config/hub <<END
---
github.com:
- user: davejamesmiller
END
    fi
}

git() {
    # Alias to hub if available
    if which ruby >/dev/null 2>&1; then
        git=hub
        init_hub
    else
        git=git
    fi

    # 'git' with no parameters loads interactive REPL
    if [ $# -gt 0 ]; then
        command $git "$@"
    else
        command $git status &&
        command $git repl
    fi
}

hub() {
    init_hub
    git "$@"
}

# Auto-complete git commands for git aliases (g, cfg, hub)
if type _git >/dev/null 2>&1; then
    for cmd in g cfg hub; do
        complete -o bashdefault -o default -o nospace -F _git $cmd 2>/dev/null ||
        complete -o default -o nospace -F _git $cmd
    done
fi

# cd to repo root
cg() {
    cd "$(git rev-parse --show-toplevel)"
}
