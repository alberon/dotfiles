# Configure X server display
if $WINDOWS || $WSL; then
    if [ -z "$DISPLAY" ]; then
        export DISPLAY=localhost:0.0
    fi
fi

# Emulate apt-get with apt-cyg
if $CYGWIN; then
    alias agi='apt-cyg install'
    alias agr='apt-cyg remove'
    alias agu='apt-cyg update'
    alias acs='apt-cyg searchall'
fi

# Expand aliases after 'winpty'
if $WINDOWS; then
    alias winpty='winpty '
fi

# Clear the MSysGit MOTD (at this point it's already been shown, but this
# gets rid of it for the future)
if $MSYSGIT; then
    if [ -w /etc/motd ]; then
        > /etc/motd
    fi
fi

# The MinTTY config file is stored outside the Git repo
if $WSL; then
    if ! cmp -s $WIN_APPDATA_UNIX/wsltty/config $HOME/.minttyrc; then
        rm -f $WIN_APPDATA_UNIX/wsltty/config
        cp $HOME/.minttyrc $WIN_APPDATA_UNIX/wsltty/config
        echo
        yellowBg black "MinTTY config updated - please reload it"
    fi
fi
