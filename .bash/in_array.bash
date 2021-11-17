# https://stackoverflow.com/a/8574392/167815
in_array () {
    local element match="$1"
    shift
    for element; do
        [[ "$e" == "$match" ]] && return 0
    done
    return 1
}
