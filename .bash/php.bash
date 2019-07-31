# See ~/bin/phpunit
alias pu='phpunit'

composer() {
    if dir="$(findup -x scripts/php.sh)"; then
        "$dir/scripts/composer.sh" "$@"
    else
        php "$@"
    fi
}

php() {
    if dir="$(findup -x scripts/php.sh)"; then
        "$dir/scripts/php.sh" "$@"
    else
        php "$@"
    fi
}
