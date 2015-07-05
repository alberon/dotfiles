host() {
    # Accept URLs and convert to domain name only
    domain=$(echo "$1" | sed 's#https\?://\([^/]*\).*/#\1#')

    if [ -n "$domain" ]; then
        shift
        command host "$domain" "$@"
    else
        command host "$@"
    fi
}
