if $WINDOWS; then

    # Set the X display, since Cygwin doesn't do it automatically
    if [ -z "$DISPLAY" ]; then
        export DISPLAY=:0
    fi

    # Emulate apt-get with apt-cyg
    if $CYGWIN; then
        alias agi='apt-cyg install'
        alias agr='apt-cyg remove'
        alias agu='apt-cyg update'
        alias acs='apt-cyg searchall'
    fi

    # Expand aliases after 'winpty'
    alias winpty='winpty '

    # Clear the MSysGit MOTD (at this point it's already been shown, but this
    # gets rid of it for the future)
    if [ -w /etc/motd ]; then
        > /etc/motd
    fi

fi
