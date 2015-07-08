#!/bin/bash
set -eu

#===============================================================================
# Helpers
#===============================================================================

is_installed() {
    which "$1" &>/dev/null
}

install() {
    if is_installed apt-get; then
        apt_install "$1"
    elif is_installed yum; then
        yum_install "$1"
    fi
}

#----------------------------------------
# APT
#----------------------------------------

apt_updated=false

apt_update() {
    if ! $apt_updated; then
        echo "Updating APT sources..."
        sudo apt-get update -qqy
        apt_updated=true
    fi
}

apt_install() {
    apt_update
    echo "Installing $1..."
    # Note: apt-get install -qq doesn't actually make it silent!
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" >/dev/null
}

#----------------------------------------
# Yum
#----------------------------------------

yum_gpg_keys_installed=false

yum_gpg_keys() {
    if ! $yum_gpg_keys_installed; then
        if [ -f /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6 ]; then
            echo "Importing GPG keys..."
            # CentOS
            sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
            # Tmux
            sudo rpm --import https://copr-be.cloud.fedoraproject.org/results/maxamillion/epel6-tmux/pubkey.gpg
        fi
        yum_gpg_keys_installed=true
    fi
}

yum_install() {
    yum_gpg_keys
    echo "Installing $1..."
    sudo yum install -q -y "$1"
}

#===============================================================================
# Main
#===============================================================================

# Install Git - required to install dotfiles
if ! is_installed git; then
    install git
fi

# Install Vim - because I like it better than any other editor
if ! is_installed vim; then
    install vim
fi

# Install tmux
if ! is_installed tmux; then

    if is_installed apt-get; then

        # Ubuntu 12.04 Precise has an old version of tmux installed by default
        if [ -f /etc/lsb-release ]; then
            source /etc/lsb-release
            if [ "$DISTRIB_RELEASE" = "12.04" ]; then
                echo "Adding ppa:pi-rho/dev repository..."
                sudo DEBIAN_FRONTEND=noninteractive apt-get install -qqy python-software-properties
                sudo add-apt-repository -y ppa:pi-rho/dev
                # http://askubuntu.com/a/197532
                sudo apt-get update -qqy -o Dir::Etc::sourcelist="sources.list.d/pi-rho-dev-$DISTRIB_CODENAME.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
            fi
        fi

        # So does Debian 7
        if [ -f /etc/debian_version -a "$(cat /etc/debian_version)" = "7.8" ]; then
            echo "Adding Backports repository..."
            echo "deb http://mirrors.kernel.org/debian wheezy-backports main" | sudo tee /etc/apt/sources.list.d/wheezy-backports.list >/dev/null
            sudo apt-get update -qqy -o Dir::Etc::sourcelist="sources.list.d/wheezy-backports.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
            apt_install tmux -t wheezy-backports
        else
            apt_install tmux
        fi


    elif is_installed yum; then

        if [ -f /etc/centos-release ] && grep -q '\s6\.[0-6]' /etc/centos-release; then

            # CentOS 6 doesn't even have anything newer than 1.6 in the repos (main or EPEL)
            echo "Installing tmux..."
            yum_gpg_keys
            sudo rpm -i http://copr-be.cloud.fedoraproject.org/results/maxamillion/epel6-tmux/epel-6-x86_64/tmux-1.9a-2.fc20/tmux-1.9a-2.el6.x86_64.rpm

        else

            yum_install tmux

        fi

    fi

fi

# Install dotfiles
if [ ! -d .git ]; then

    # Based on https://djm.me/cfg but quiet and non-interactive
    echo "Installing dotfiles in $HOME..."
    git init -q
    git remote add origin git://github.com/alberon/dotfiles.git
    git remote set-url --push origin git@github.com:alberon/dotfiles.git
    git fetch -q origin
    rm -f .bashrc .bash_profile
    git checkout origin/master -b master >/dev/null 2>&1
    ~/bin/cfg-install
    ~/bin/cfg-update

    # Go straight to the Vagrant directory when logging in for the first time
    echo "/vagrant" > ~/.bash_lastdirectory

fi

# Install root dotfiles
sudo -s <<END
    if [ ! -d ~root/.git ]; then
        echo "Installing dotfiles in $(echo ~root)..."
        cd ~root
        git init -q
        git remote add origin git://github.com/alberon/dotfiles.git
        git remote set-url --push origin git@github.com:alberon/dotfiles.git
        git fetch -q origin
        rm -f .bashrc .bash_profile
        git checkout origin/master -b master >/dev/null 2>&1
        ~/bin/cfg-install
        ~/bin/cfg-update
    fi
END

# Allow access to the root user
if [ -f ~/.ssh/alberon.pub ]; then
    sudo cp -f ~/.ssh/alberon.pub ~root/.ssh/authorized_keys
fi
