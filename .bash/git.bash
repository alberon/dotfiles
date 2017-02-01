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

# cd to repo root
cg() {
    # Look in parent directories
    path="$(git rev-parse --show-toplevel 2>/dev/null)"

    # Look in child directories
    if [ -z "$path" ]; then
        path="$(find . -mindepth 2 -maxdepth 2 -type d -name .git 2>/dev/null)"
        if [ $(echo "$path" | wc -l) -gt 1 ]; then
            echo "Multiple repositories found:" >&2
            echo "$path" | sed 's/^.\//  /g; s/.git$//g' >&2
            return
        else
            path="${path%/.git}"
        fi
    fi

    # Go to the directory, if found
    if [ -n "$path" ]; then
        c "$path"
    else
        echo "No Git repository found in parent directories or immediate children" >&2
    fi
}

# Workaround for Git hanging when using Composer
# Currently disabled because it doesn't work in Vagrant provisioner, and I don't
# need it right now because I disabled ControlMaster as it's not supported in Cygwin
#export GIT_SSH='ssh-noninteractive'
