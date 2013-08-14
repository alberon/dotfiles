if $HAS_TERMINAL; then

    # rvm
    rvm_project_rvmrc=0 # RVM 1.22.1 breaks my 'cd' alias, and I don't need this

    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

    # Use bundle exec to run these Rails commands
    alias guard="bundle exec guard"
    alias capify="bundle exec capify"
    alias cap="bundle exec cap"
    alias rake="bundle exec rake"

fi
