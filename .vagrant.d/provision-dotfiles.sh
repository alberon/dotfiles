#!/bin/bash
set -eu

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
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $1 >/dev/null
}

# Install Git - required to install dotfiles
if ! which git &>/dev/null; then
    apt_install git
fi

# Install Vim - because I like it better than any other editor
if ! which vim &>/dev/null; then
    apt_install vim
fi

# Install tmux
if ! which tmux &>/dev/null; then

    # Ubuntu 12.04 Precise has an old version of tmux installed by default
    if [ -f /etc/lsb-release ]; then
        source /etc/lsb-release
        if [ "$DISTRIB_RELEASE" = "12.04" ]; then
            echo "Adding ppa:pi-rho/dev repository..."
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -qqy python-software-properties
            sudo add-apt-repository -y ppa:pi-rho/dev
            # http://askubuntu.com/a/197532
            sudo apt-get update -qqy -o Dir::Etc::sourcelist="sources.list.d/pi-rho-dev-precise.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
        fi
    fi

    apt_install tmux

fi

# Install dotfiles
if [ ! -d .git ]; then

    # Based on https://djm.me/cfg but quiet and non-interactive
    echo "Installing dotfiles in $HOME..."
    git init -q
    git remote add origin git://github.com/davejamesmiller/dotfiles.git
    git remote set-url --push origin git@github.com:davejamesmiller/dotfiles.git
    git fetch -q origin
    rm .bashrc
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
        cd
        git init -q
        git remote add origin git://github.com/davejamesmiller/dotfiles.git
        git remote set-url --push origin git@github.com:davejamesmiller/dotfiles.git
        git fetch -q origin
        rm .bashrc
        git checkout origin/master -b master >/dev/null 2>&1
        ~/bin/cfg-install
        ~/bin/cfg-update
    fi
END

# Allow access to the root user
sudo cp -f ~/.ssh/davejamesmiller.pub ~root/.ssh/authorized_keys
