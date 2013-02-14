if $HAS_TERMINAL; then

    # rvm
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

    # Use bundle exec to run these Rails commands
    alias guard="bundle exec guard"
    alias capify="bundle exec capify"
    alias cap="bundle exec cap"
    alias rake="bundle exec rake"

fi
