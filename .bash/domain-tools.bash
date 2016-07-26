domain_command() {
    command="$1"
    shift

    # Accept URLs and convert to domain name only
    domain=$(echo "$1" | sed 's#https\?://\([^/]*\).*/#\1#')

    if [ -n "$domain" ]; then
        shift
        command $command "$domain" "$@"
    else
        command $command "$@"
    fi
}

alias host="domain_command host"
alias nslookup="domain_command nslookup"
alias whois="domain_command whois"
