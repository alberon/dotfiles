#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Update Apt repositories
apt-get -y update

# Install Git
if ! which git >/dev/null 2>&1; then
    apt-get install -y git
fi

# Install tmux
if ! which tmux >/dev/null 2>&1; then

    # Ubuntu 12.04 Precise has an old version of tmux installed by default
    if [ -f /etc/lsb-release ]; then
        source /etc/lsb-release
        if [ "$DISTRIB_RELEASE" = "12.04" ]; then
            apt-get install -y python-software-properties
            add-apt-repository -y ppa:pi-rho/dev 2>&1
            # http://askubuntu.com/a/197532
            apt-get -y update -o Dir::Etc::sourcelist="sources.list.d/pi-rho-dev-precise.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
        fi
    fi

    apt-get install -y tmux

fi
