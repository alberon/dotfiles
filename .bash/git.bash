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
    cd "$(git rev-parse --show-toplevel)"
}

# Workaround for Git hanging when using Composer
# Currently disabled because it doesn't work in Vagrant provisioner, and I don't
# need it right now because I disabled ControlMaster as it's not supported in Cygwin
#export GIT_SSH='ssh-noninteractive'
