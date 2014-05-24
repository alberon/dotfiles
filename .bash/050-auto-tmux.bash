# Workaround for losing SSH agent connection when reconnecting tmux: update a
# symlink to the socket each time we reconnect and use that as the socket in
# every session. First we make sure there's a valid socket connecting us to the
# agent and it's not already pointing to the symlink:
if [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/ssh_auth_sock" -a -S "$SSH_AUTH_SOCK" ]; then
    # We also check if the agent has any keys loaded - PuTTY will still open an
    # agent connection even if we used password authentication
    if ssh-add -l >/dev/null 2>&1; then
        ln -nsf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
    fi
fi

# Now that's done we can use the symlink for every session
export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"

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

