# See ~/bin/phpunit
alias ide='t ide-helper'
alias mfs='art migrate:fresh --seed'
alias pu='phpunit'

composer() {
    if dir="$(findup -x scripts/composer.sh)"; then
        "$dir/scripts/composer.sh" "$@"
    else
        command composer "$@"
    fi
}

php() {
    if dir="$(findup -x scripts/php.sh)"; then
        "$dir/scripts/php.sh" "$@"
    else
        command php "$@"
    fi
}
