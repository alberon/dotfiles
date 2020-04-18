phpstorm() {
    if [ $# -gt 0 ]; then
        command phpstorm "$@" &>> ~/tmp/phpstorm.log &
    elif [ -d .idea ]; then
        command phpstorm "$PWD" &>> ~/tmp/phpstorm.log &
    else
        command phpstorm &>> ~/tmp/phpstorm.log &
    fi
}

alias storm='phpstorm'
