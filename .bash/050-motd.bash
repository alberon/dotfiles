if [ -n "$TMUX" ]; then
    # Show the MOTD inside tmux, since it won't be shown if we load tmux
    # immediately from ssh instead of Bash
    if [ -f /run/motd.dynamic ]; then
        cat /run/motd.dynamic
        hr="$(printf "%${COLUMNS}s" | tr ' ' -)"
        echo -e "\033[30;1m$hr\033[0m"
    fi
fi
