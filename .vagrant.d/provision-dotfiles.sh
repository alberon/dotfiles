#!/bin/bash

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
