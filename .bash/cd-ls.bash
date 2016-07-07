if $HAS_TERMINAL; then

    # Remember the last directory visited
    record_bash_lastdirectory() {
        pwd > ~/.bash_lastdirectory
    }

    cd() {
        command cd "$@" && record_bash_lastdirectory
    }

    # Change to the last visited directory, unless we're already in a different directory
    if [ "$PWD" = "$HOME" ]; then
        if [ -f ~/.bash_lastdirectory ]; then
            # Throw away errors about that directory not existing (any more)
            command cd "$(cat ~/.bash_lastdirectory)" 2>/dev/null
        elif [ -n "$www_dir" ]; then
            # If this is the first login, try going to the web root instead
            # Mainly useful for Vagrant boxes
            cd "$www_dir"
        fi
    fi

    # Detect typos in the cd command
    shopt -s cdspell

    # Need some different options for ls on Mac
    if $MAC; then
        # Mac
        ls_opts='-G'
        # Use the same color scheme as Debian
        # http://geoff.greer.fm/lscolors/
        export LSCOLORS=ExGxFxDaCaDaDahbaDacec
    elif ls --hide=*.pyc >/dev/null 2>&1; then
        # Recent Linux
        ls_opts='--color=always --hide=*.pyc --hide=*.sublime-workspace'
    else
        # Old Linux (without --hide support)
        ls_opts='--color=always'
    fi

    # c = cd; ls
    c() {

        # cd to the given directory
        if [[ "$@" != "." ]]; then
            # If "." don't do anything, so that "cd -" still works
            # Don't output the path as I'm going to anyway (done by "cd -" and cdspell)
            cd "$@" >/dev/null || return
        fi

        # Output the path
        echo
        echo -en "\033[4;1m"
        echo $PWD
        echo -en "\033[0m"

        # List the directory contents
        ls -hF $ls_opts

    }

    # Various shortcuts for `ls`
    # ls, lsa   = short format
    # l,  la    = long format
    # ll, lla   = long format (deprecated)
    alias ls="ls -hF $ls_opts"
    alias lsa="ls -hFA $ls_opts"

    alias l="ls -hFl $ls_opts"
    alias la="ls -hFlA $ls_opts"

    # Old aliases
    alias ll='l'
    alias lla='la'

    # Use colours for 'tree' too
    alias tree='tree -C'

    # Unset the colours that are sometimes set (e.g. Joshua)
    export LS_COLORS=

    # Stop newer versions of Bash quoting the filenames in ls
    # http://unix.stackexchange.com/a/258687/14368
    export QUOTING_STYLE=literal

    # u = up
    alias u='c ..'
    alias uu='c ../..'
    alias uuu='c ../../..'
    alias uuuu='c ../../../..'
    alias uuuuu='c ../../../../..'
    alias uuuuuu='c ../../../../../..'

    # b = back
    alias b='c -'

    # cw = web files directory
    if [ -n "$www_dir" ]; then
        alias cw="c $www_dir"
    fi

fi
