if $HAS_TERMINAL && ! $WINDOWS; then

    # s=sudo
    s() {
        if [[ $# == 0 ]]; then
            sudo $(history -p '!!')
        else
            sudo "$@"
        fi
    }

    # se. = se . (sudoedit - browse current directory)
    alias se.="se ."

    # Versions of 'sudo ls'
    alias sl='sudo ls -hF --color=always'
    alias sls='sudo ls -hF --color=always'
    alias sll='sudo ls -hFl --color=always'
    alias sla='sudo ls -hFA --color=always'
    alias slla='sudo ls -hFlA --color=always'

    # apt-get
    alias agi='sudo apt-get install'
    alias agr='sudo apt-get remove'
    alias agar='sudo apt-get autoremove'
    alias agu='sudo apt-get update && sudo apt-get upgrade'
    alias agupdate='sudo apt-get update'
    alias agupgrade='sudo apt-get upgrade'
    alias acs='apt-cache search'
    alias acsh='apt-cache show'

    # These commands require sudo
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
    alias pow='sudo poweroff'
    alias poweroff='sudo poweroff'
    alias reboot='sudo reboot'
    alias service='sudo service'
    alias shutdown='sudo poweroff'
    alias useradd='sudo useradd'
    alias userdel='sudo userdel'
    alias usermod='sudo usermod'
    alias yum='sudo yum'

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

fi
