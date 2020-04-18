redis()
{
    if [[ $# -ge 1 ]] && [[ $1 =~ ^[0-9]+$ ]]; then
        # e.g. "redis 1"
        redis-cli -n "$@"
    else
        redis-cli "$@"
    fi
}
