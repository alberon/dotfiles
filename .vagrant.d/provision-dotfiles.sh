#!/bin/bash
set -eu

apt_updated=false
apt_update() {
    if ! $apt_updated; then
        sudo apt-get update -y
        apt_updated=true
    fi
}

# Install Git - required to install dotfiles
if ! which git &>/dev/null; then
    apt_update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git
fi

# Install Vim - because I like it better than any other editor
if ! which vim &>/dev/null; then
    apt_update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y vim
fi

# Install tmux
if ! which tmux &>/dev/null; then

    # Ubuntu 12.04 Precise has an old version of tmux installed by default
    if [ -f /etc/lsb-release ]; then
        source /etc/lsb-release
        if [ "$DISTRIB_RELEASE" = "12.04" ]; then
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python-software-properties
            sudo add-apt-repository -y ppa:pi-rho/dev 2>&1
            # http://askubuntu.com/a/197532
            sudo apt-get update -y -o Dir::Etc::sourcelist="sources.list.d/pi-rho-dev-precise.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
        fi
    fi

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y tmux

fi

# Install dotfiles
if [ ! -d .git ]; then

    # Based on https://djm.me/cfg but non-interactive
    git init
    git remote add origin git://github.com/davejamesmiller/dotfiles.git
    git remote set-url --push origin git@github.com:davejamesmiller/dotfiles.git
    git fetch origin 2>&1
    rm .bashrc
    git checkout origin/master -b master 2>&1
    ~/bin/cfg-install
    ~/bin/cfg-update

    # Go straight to the Vagrant directory when logging in for the first time
    echo "/vagrant" > ~/.bash_lastdirectory

fi

# Install root dotfiles
sudo -s <<END
    if [ ! -d ~root/.git ]; then
        cd
        git init
        git remote add origin git://github.com/davejamesmiller/dotfiles.git
        git remote set-url --push origin git@github.com:davejamesmiller/dotfiles.git
        git fetch origin 2>&1
        rm .bashrc
        git checkout origin/master -b master 2>&1
        ~/bin/cfg-install
        ~/bin/cfg-update
    fi
END
