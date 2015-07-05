if $HAS_TERMINAL; then

    # rvm
    rvm_project_rvmrc=0 # RVM 1.22.1 breaks my 'cd' alias, and I don't need this

    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

fi
