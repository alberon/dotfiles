if $HAS_TERMINAL && ! $WINDOWS; then

    # s=sudo
    s() {
        if [[ $# == 0 ]]; then
            # Use eval to expand aliases
            eval "sudo $(history -p '!!')"
        else
            sudo "$@"
        fi
    }

    # apt (formerly apt-get and apt-cache)
    if [ $UID -eq 0 ]; then
        alias agi='apt install'
        alias agr='apt remove'
        alias agar='apt autoremove'
        alias agu='apt update && apt full-upgrade'
        alias agupdate='apt update'
        alias agupgrade='apt upgrade'
    else
        alias agi='sudo apt install'
        alias agr='sudo apt remove'
        alias agar='sudo apt autoremove'
        alias agu='sudo apt update && sudo apt full-upgrade'
        alias agupdate='sudo apt update'
        alias agupgrade='sudo apt upgrade'
    fi

    alias acs='apt search'
    alias acsh='apt show'

    # Power aliases
    if [ $UID -eq 0 ]; then
        alias pow='poweroff'
        alias shutdown='poweroff'
    else
        alias pow='sudo poweroff'
        alias shutdown='sudo poweroff'
    fi

    # These commands require sudo
    if [ $UID -ne 0 ]; then
        alias a2dismod='sudo a2dismod'
        alias a2dissite='sudo a2dissite'
        alias a2enmod='sudo a2enmod'
        alias a2ensite='sudo a2ensite'
        alias addgroup='sudo addgroup'
        alias adduser='sudo adduser'
        alias dpkg-reconfigure='sudo dpkg-reconfigure'
        alias groupadd='sudo groupadd'
        alias groupdel='sudo groupdel'
        alias groupmod='sudo groupmod'
        alias php5dismod='sudo php5dismod'
        alias php5enmod='sudo php5enmod'
        alias phpdismod='sudo phpdismod'
        alias phpenmod='sudo phpenmod'
        alias poweroff='sudo poweroff'
        alias reboot='sudo reboot'
        alias service='sudo service'
        alias snap='sudo snap'
        alias ufw='sudo ufw'
        alias updatedb='sudo updatedb'
        alias useradd='sudo useradd'
        alias userdel='sudo userdel'
        alias usermod='sudo usermod'
        alias yum='sudo yum'
    fi

    systemctl() {
        if [ "$1" = "list-units" ]; then
            # The 'list-units' subcommand is used by tab completion
            command systemctl "$@"
        else
            command sudo systemctl "$@"
        fi
    }

    # Add sbin folder to my path so they can be auto-completed
    PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"

    # Add additional safety checks for cp, mv, rm
    sudo() {
        if [ "$1" = "cp" -o "$1" = "mv" -o "$1" = "rm" ]; then
            exe="$1"
            shift
            command sudo "$exe" -i "$@"
        else
            command sudo "$@"
        fi
    }

    # Expand aliases after sudo - e.g. 'sudo ll'
    # http://askubuntu.com/a/22043/29806
    alias sudo='sudo '
    alias s='s '

fi
