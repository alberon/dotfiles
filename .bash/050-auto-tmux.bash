# Immediately switch to tmux if possible
# This is better than changing the shell to tmux because it can be set to attach
# to a running session if there is one
if $HAS_TERMINAL && [[ ! $TERM =~ screen ]] && which tmux >/dev/null 2>&1; then
    if tmux has-session 2>/dev/null; then
        exec tmux attach
    else
        exec tmux new -s default
    fi
fi

