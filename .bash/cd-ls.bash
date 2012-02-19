if $HAS_TERMINAL; then

    # Remember the last directory visited
    function record_bash_lastdirectory {
        pwd > ~/.bash_lastdirectory
    }

    function cd {
        command cd "$@" && record_bash_lastdirectory
    }

    # Go to home directory by default
    command cd

    # Then go to the last visited directory, if possible
    if [ -f ~/.bash_lastdirectory ]; then
        # Throw away errors about that directory not existing (any more)
        command cd "`cat ~/.bash_lastdirectory`" 2>/dev/null
    fi

    # Detect typos in the cd command
    shopt -s cdspell

    # c = cd; ls
    function c {

        # cd to the first argument
        if [ "$1" = "" ]; then
            # If none then go to ~ like cd does
            cd || return
        elif [ "$1" != "." ]; then
            # If "." don't do anything, so that "cd -" still works
            # Don't output the path as I'm going to anyway (done by "cd -" and cdspell)
            cd "$1" >/dev/null || return
        fi

        # Remove that argument
        shift

        # Output the path
        echo
        echo -en "\e[4;1m"
        echo $PWD
        echo -en "\e[0m"

        # Then pass the rest to ls (just in case we have any use for that!)
        ls -h --color=always "$@"

    }

    #export -f c

    # Various shortcuts for `ls`
    alias ls='ls -hF --color=always'
    alias ll='ls -hFl --color=always'
    alias la='ls -hFA --color=always'
    alias lla='ls -hFlA --color=always'

    function l {
        if [ -z "$*" ]; then
            # Show current directory name above the listing
            c .
        else
            # If there's any other options I can't be bothered to parse them
            # so just pass them to ls
            ls "$@"
        fi
    }

    # Unset the colours that are sometimes set (e.g. Joshua)
    export LS_COLORS=

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
