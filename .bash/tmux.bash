# Currently not working on Mac
# But not using tmux on Mac anyway so it'll do for now!
if ! $MAC; then

    # tmux attach (local)
    tm() {
        local name="${1:-default}"

        if [ -z "$TMUX" ] && [[ "$TERM" != screen* ]]; then
            tmux -2 new -A -s "$name"
        else
            tmux -2 new -d -s "$name" 2>/dev/null
            tmux -2 switch -t "$name"
        fi
    }

    # ssh + tmux ('h' for 'ssH', because 's' is in use)
    h() {
        local host="$1"
        local name="${2:-default}"
        local path="${3:-.}"

        # Special case for 'h vagrant' / 'h v' ==> 'v h' => 'vagrant tmux' (see vagrant.bash)
        if [ "$host" = "v" -o "$host" = "vagrant" ] && [ $# -eq 1 ]; then
            vagrant tmux
            return
        fi

        # For 'h user@host ^', upload SSH public key - easier than retyping it
        if [ $# -eq 2 -a "$name" = "^" ]; then
            ssh-copy-id "$host"
            return
        fi

        # For 'h user@host X', close the master connection
        if [ $# -eq 2 -a "$name" = "X" ]; then
            ssh -O stop "$host"
            return
        fi

        # Not running tmux
        if [ -z "$TMUX" ] && [[ "$TERM" != screen* ]]; then

            local server="${host#*@}"

            case $server in
                # Run tmux on the local machine, as it's not available on the remote server
                a|aria|b|baritone|d|dragon|f|forte|t|treble)

                    # The name defaults to the host name given, rather than 'default'
                    name="${2:-$host}"

                    # Create a detached session (if there isn't one already)
                    tmux -2 new -s "$name" -d "ssh -o ForwardAgent=yes -t '$host' 'cd \"$path\"; bash -l'"

                    # Set the default command for new windows to connect to the same server, so we can have multiple panes
                    tmux set -t "$name" default-command "ssh -o ForwardAgent=yes -t '$host' 'cd \"$path\"; bash -l'"

                    # Connect to the session
                    tmux -2 attach -t "$name"

                    ;;

                # Run tmux on the remote server
                *)
                    ssh -o ForwardAgent=yes -t "$host" "cd '$path'; command -v tmux &>/dev/null && tmux -2 new -A -s '$name' || bash -l"
                    ;;
            esac

            return
        fi

        # Already running tmux *and* the user tried to specify a session name
        if [ $# -ge 2 ]; then
            echo 'sessions should be nested with care, unset $TMUX to force' >&2
            return 1
        fi

        # Already running tmux so connect without it
        ssh -o ForwardAgent=yes "$host"
    }

fi
