# Currently not working on Mac
# But not using tmux on Mac anyway so it'll do for now!
if ! $MAC; then

    # tmux attach (local)
    # The 'sleep' seems to be necessary in tmux 2.0 on Ubuntu - otherwise the
    # second command fails... I have no idea why!
    alias tm='tmux -2 attach || { sleep 0.001; tmux -2 new -s default; }'

    # ssh + tmux ('h' for 'host' or 'ssH', because 's' and 't' are in use)
    h() {
        local host="$1"
        local name="${2:-default}"
        local path="${3:-.}"

        if [ "$host" = "v" -o "$host" = "vagrant" ] && [ $# -eq 1 ]; then
            # Special case for 'h vagrant' / 'h v' => 'v h' => 'vagrant tmux' (see vagrant.bash)
            vagrant tmux
        elif [ $# -eq 2 -a "$name" = "^" ]; then
            # For 'h user@host ^' upload SSH public key - easier than retyping it
            ssh-copy-id "$host"
        elif [ -z "$TMUX" ] && [[ "$TERM" != screen* ]]; then
            # Run tmux over ssh
            ssh -o ForwardAgent=yes -t "$host" "cd '$path'; command -v tmux &>/dev/null && { tmux -2 attach -t '$name' || { sleep 0.001; tmux -2 new -s '$name'; }; } || bash -l"
        elif [ $# -ge 2 ]; then
            # Already running tmux *and* the user tried to specify a session name
            echo 'sessions should be nested with care, unset $TMUX to force' >&2
            return 1
        else
            # Already running tmux so connect without it
            autoname="$(tmux display-message -pt $TMUX_PANE '#{automatic-rename}')"

            if [ "$autoname" = 1 ]; then
                tmux rename-window -t $TMUX_PANE "$host" 2>/dev/null
            fi

            ssh -o ForwardAgent=yes "$host"

            if [ "$autoname" = 1 ]; then
                tmux setw -t $TMUX_PANE automatic-rename 2>/dev/null
                sleep 0.3 # Need a short delay else the window is named 'tmux' not 'bash'
            fi
        fi
    }

    # mosh + tmux
    export MOSH_TITLE_NOPREFIX=1

    m() {
        local host="$1"
        local name="${2:-default}"
        local path="${3:-.}"

        if [ -z "$TMUX" ]; then
            # Run tmux over mosh (https://mosh.org/)
            mosh --ssh="ssh -o ForwardAgent=yes -tt" "$host" -- sh -c "cd '$path'; command -v tmux &>/dev/null && { tmux -2 attach -t '$name' || { sleep 0.001; tmux -2 new -s '$name'; }; } || bash -l"
        elif [ $# -ge 2 ]; then
            # Already running tmux *and* the user tried to specify a session name
            echo 'sessions should be nested with care, unset $TMUX to force' >&2
            return 1
        else
            # Already running tmux so connect without it
            mosh --ssh="ssh -o ForwardAgent=yes" "$host"
        fi
    }

fi
