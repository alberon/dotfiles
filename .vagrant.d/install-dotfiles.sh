#!/bin/bash

# Update Apt repositories
sudo apt-get -y update

# Install Git
if ! which git >/dev/null 2>&1; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git
fi

# Install tmux
if ! which tmux >/dev/null 2>&1; then
    if [ -f /etc/lsb-release ]; then
        source /etc/lsb-release
        if [ "$DISTRIB_RELEASE" = "12.04" ]; then
            # Ubuntu 12.04 Precise has an old version of tmux installed by default
            sudo apt-get install -y python-software-properties
            sudo add-apt-repository -y ppa:pi-rho/dev
        fi
    fi
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y tmux
fi

# Based on https://djm.me/cfg but non-interactive
if [ ! -d .git ]; then
    git init
    git remote add origin git://github.com/davejamesmiller/dotfiles.git
    git remote set-url --push origin git@github.com:davejamesmiller/dotfiles.git
    git fetch origin
    rm .bashrc
    git checkout origin/master -b master 2>&1
    ~/bin/cfg-install
    ~/bin/cfg-update
fi
