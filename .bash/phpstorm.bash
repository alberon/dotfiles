phpstorm() {
    if [ $# -gt 0 ]; then
        command phpstorm "$@" &
    elif [ -d .idea ]; then
        command phpstorm "$PWD" &
    else
        command phpstorm &
    fi
}
