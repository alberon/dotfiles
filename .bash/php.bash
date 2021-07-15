alias com='composer'
alias ide='t ide-helper'
alias mfs='art migrate:fresh --drop-views --seed'
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

hackit() {
    # Has to be a function because it deletes the working directory
    if [ "$(basename "$(dirname "$(dirname "$PWD")")")" != "vendor" ]; then
        echo "Not in a Composer vendor directory" >&2
        return 1
    fi

    if [ -e .git ]; then
        echo "Already in development mode" >&2
        return 1
    fi

    ask "Delete this directory and reinstall in development mode?" Y || return

    local package="$(basename "$(dirname "$PWD")")/$(basename "$PWD")"
    local oldpwd="${OLDPWD:-}"
    local pwd="$PWD"

    # Delete the dist version
    cd ../../..
    rm -rf "$pwd"

    # Install the dev version
    composer update --prefer-source "$package"

    # Go back to that directory + restore "cd -" path
    cd "$pwd"
    OLDPWD="$oldpwd"

    # Switch to the latest development version
    # TODO: Detect when 'master' is not the main branch?
    git checkout master
}

hacked() {
    if [ "$(basename "$(dirname "$(dirname "$PWD")")")" != "vendor" ]; then
        echo "Not in a Composer vendor directory" >&2
        return 1
    fi

    if [ ! -e .git ]; then
        echo "Not in development mode" >&2
        return 1
    fi

    if [ -n "$(git status --porcelain)" ]; then
        echo "There are uncommitted changes" >&2
        return 1
    fi

    ask "Delete this directory and reinstall in production mode?" Y || return

    local package="$(basename "$(dirname "$PWD")")/$(basename "$PWD")"
    local oldpwd="${OLDPWD:-}"
    local pwd="$PWD"

    # Delete the dev version
    cd ../../..
    rm -rf "$pwd"

    # Install the dist version
    composer update --prefer-dist "$package"

    # Go back to that directory + restore "cd -" path
    cd "$pwd"
    OLDPWD="$oldpwd"
}

xdebug() {
    if [[ ${1:-} = 'on' ]]; then
        export XDEBUG_SESSION=${2:-1}
    elif [[ ${1:-} = 'off' ]]; then
        unset XDEBUG_SESSION
    fi

    if [[ ${XDEBUG_SESSION:-} = 1 ]]; then
        echo "Xdebug step debugging is enabled"
    elif [[ -n ${XDEBUG_SESSION:-} ]]; then
        echo "Xdebug step debugging is enabled (trigger_value=$XDEBUG_SESSION)"
    else
        echo "Xdebug step debugging is disabled"
    fi
}
