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

    # se. = se . (sudoedit - browse current directory)
    alias se.="se ."

    # Versions of 'sudo ls'
    alias sl='sudo l'
    alias sls='sudo ls'
    alias sll='sudo ll'
    alias sla='sudo la'
    alias slla='sudo lla'

    # apt-get
    maybe_sudo() {
        if [ $UID -eq 0 ]; then
            command "$@"
        else
            sudo "$@"
        fi
    }

    alias agi='maybe_sudo apt-get install'
    alias agr='maybe_sudo apt-get remove'
    alias agar='maybe_sudo apt-get autoremove'
    alias agu='maybe_sudo apt-get update && maybe_sudo apt-get upgrade'
    alias agupdate='maybe_sudo apt-get update'
    alias agupgrade='maybe_sudo apt-get upgrade'
    alias acs='apt-cache search'
    alias acsh='apt-cache show'

    # These commands require sudo
    alias a2dismod='maybe_sudo a2dismod'
    alias a2dissite='maybe_sudo a2dissite'
    alias a2enmod='maybe_sudo a2enmod'
    alias a2ensite='maybe_sudo a2ensite'
    alias addgroup='maybe_sudo addgroup'
    alias adduser='maybe_sudo adduser'
    alias dpkg-reconfigure='maybe_sudo dpkg-reconfigure'
    alias groupadd='maybe_sudo groupadd'
    alias groupdel='maybe_sudo groupdel'
    alias groupmod='maybe_sudo groupmod'
    alias php5dismod='maybe_sudo php5dismod'
    alias php5enmod='maybe_sudo php5enmod'
    alias phpdismod='maybe_sudo phpdismod'
    alias phpenmod='maybe_sudo phpenmod'
    alias pow='maybe_sudo poweroff'
    alias poweroff='maybe_sudo poweroff'
    alias reboot='maybe_sudo reboot'
    alias service='maybe_sudo service'
    alias shutdown='maybe_sudo poweroff'
    alias useradd='maybe_sudo useradd'
    alias userdel='maybe_sudo userdel'
    alias usermod='maybe_sudo usermod'
    alias yum='maybe_sudo yum'

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
