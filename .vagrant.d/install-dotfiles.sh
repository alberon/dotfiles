#!/bin/bash

# Install Git
if ! which git >/dev/null 2>&1; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git
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
