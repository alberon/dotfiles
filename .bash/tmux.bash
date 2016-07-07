# Currently not working on Mac
# But not using tmux on Mac anyway so it'll do for now!
if ! $MAC; then

    # Workaround for losing SSH agent connection when reconnecting tmux: update a
    # symlink to the socket each time we reconnect and use that as the socket in
    # every session. First we make sure there's a valid socket connecting us to the
    # agent and it's not already pointing to the symlink, and there's no existing
    # working symlink:
    link="$HOME/.ssh/ssh_auth_sock"
    if [ "$SSH_AUTH_SOCK" != "$link" -a -S "$SSH_AUTH_SOCK" -a ! -S "$link" ]; then
        # We also check if the agent has any keys loaded - PuTTY will still open an
        # agent connection even if we used password authentication
        if ssh-add -l >/dev/null 2>&1; then
            ln -nsf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
        fi
    fi

    # Now that's done we can use the symlink for every session
    export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"

    # tmux attach (local)
    # The 'sleep' seems to be necessary in tmux 2.0 on Ubuntu - otherwise the
    # second command fails... I have no idea why!
    alias tm='tmux -2 attach || { sleep 0.001; tmux -2 new -s default; }'

    # ssh + tmux ('h' for 'host' or 'ssH', because 's' and 't' are in use)
    h() {
        host="$1"

        if [ -z "$TMUX" ]; then
            name="${2:-default}"
            ssh -o ForwardAgent=yes -t "$host" "which tmux >/dev/null 2>&1 && { tmux -2 attach -t '$name' || { sleep 0.001; tmux -2 new -s '$name'; }; } || bash -l"
        elif [ $# -ge 2 ]; then
            echo 'sessions should be nested with care, unset $TMUX to force' >&2
            return 1
        else
            ssh -o ForwardAgent=yes "$host"
        fi
    }

fi
