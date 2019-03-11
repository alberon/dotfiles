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

    # apt-get
    if [ $UID -eq 0 ]; then
        alias agi='apt-get install'
        alias agr='apt-get remove'
        alias agar='apt-get autoremove'
        alias agu='apt-get update && apt-get upgrade'
        alias agdu='apt-get dist-upgrade'
        alias agupdate='apt-get update'
        alias agupgrade='apt-get upgrade'
    else
        alias agi='sudo apt-get install'
        alias agr='sudo apt-get remove'
        alias agar='sudo apt-get autoremove'
        alias agu='sudo apt-get update && sudo apt-get upgrade'
        alias agdu='sudo apt-get dist-upgrade'
        alias agupdate='sudo apt-get update'
        alias agupgrade='sudo apt-get upgrade'
    fi

    alias acs='apt-cache search'
    alias acsh='apt-cache show'

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
