#!/bin/bash
set -eu

#===============================================================================
# Settings
#===============================================================================

github_user=jagfiend
public_key=~/.ssh/pete.pub

#===============================================================================
# Helpers
#===============================================================================

maybe_sudo()
{
    if [ $UID -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

is_installed()
{
    command -v "$1" &>/dev/null
}

install()
{
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

apt_update()
{
    if ! $apt_updated; then
        echo "Updating APT sources..."
        maybe_sudo apt-get update -qqy
        apt_updated=true
    fi
}

apt_install()
{
    apt_update
    echo "Installing $1..."
    # Note: apt-get install -qq doesn't actually make it silent!
    maybe_sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" >/dev/null
}

#----------------------------------------
# Yum
#----------------------------------------

yum_gpg_keys_installed=false

yum_gpg_keys()
{
    if ! $yum_gpg_keys_installed; then
        if [ -f /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6 ]; then
            echo "Importing GPG keys..."
            # CentOS
            maybe_sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
            # Tmux
            maybe_sudo rpm --import https://copr-be.cloud.fedoraproject.org/results/maxamillion/epel6-tmux/pubkey.gpg
        fi
        yum_gpg_keys_installed=true
    fi
}

yum_install()
{
    yum_gpg_keys
    echo "Installing $1..."
    maybe_sudo yum install -q -y "$1"
}

#===============================================================================
# Main
#===============================================================================

# Git
if ! is_installed git; then
    install git
fi

# Vim
if ! is_installed vim; then
    install vim
fi

# BC (required below)
if ! is_installed bc; then
    install bc
fi

#---------------------------------------
# tmux
#---------------------------------------

compare()
{
    [ "$(echo "$1" | bc)" = 1 ]
}

install_tmux()
{
    # Already installed *and* up to date?
    if is_installed tmux; then
        version="$(tmux -V | egrep -o '[0-9]+\.[0-9]+')"
        if [ -n "$version" ] && compare "$version >= 1.9"; then
            return
        fi
    fi

    # Ubuntu 12.04, 14.04, etc.
    if [ -f /etc/lsb-release ]; then
        source /etc/lsb-release
        if [ "$DISTRIB_ID" = "Ubuntu" ] && compare "$DISTRIB_RELEASE <= 14.04"; then
            echo "Adding ppa:pi-rho/dev repository..."
            maybe_sudo DEBIAN_FRONTEND=noninteractive apt-get install -qqy python-software-properties >/dev/null
            maybe_sudo add-apt-repository -y ppa:pi-rho/dev >/dev/null 2>&1
            # http://askubuntu.com/a/197532
            maybe_sudo apt-get update -qqy -o Dir::Etc::sourcelist="sources.list.d/pi-rho-dev-$DISTRIB_CODENAME.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
            apt_install tmux
            return
        fi
    fi

    # Debian 7.x
    if [ -f /etc/debian_version ] && grep -q '^7\.[0-8]$' /etc/debian_version ]; then
        echo "Adding Backports repository..."
        echo "deb http://mirrors.kernel.org/debian wheezy-backports main" | maybe_sudo tee /etc/apt/sources.list.d/wheezy-backports.list >/dev/null
        maybe_sudo apt-get update -qqy -o Dir::Etc::sourcelist="sources.list.d/wheezy-backports.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
        apt_install tmux -t wheezy-backports
        return
    fi

    # CentOS 6.x doesn't even have anything newer than 1.6 in the repos (main or
    # EPEL) - so install from this third party source
    if [ -f /etc/centos-release ] && grep -q '\s6\.[0-6]' /etc/centos-release; then
        echo "Installing tmux..."
        yum_gpg_keys
        maybe_sudo rpm -i http://copr-be.cloud.fedoraproject.org/results/maxamillion/epel6-tmux/epel-6-x86_64/tmux-1.9a-2.fc20/tmux-1.9a-2.el6.x86_64.rpm
        return
    fi

    # Anything else - probably can't upgrade, but attempt to install if it's missing
    if ! is_installed tmux; then
        install tmux
    fi
}

install_tmux

#---------------------------------------
# dotfiles
#---------------------------------------

if [ ! -d "$HOME/.git" ]; then

    # Based on https://alberon.uk/cfg but quiet and non-interactive
    echo "Installing dotfiles in $HOME..."
    cd $HOME
    git init -q
    git remote add origin "git://github.com/$github_user/dotfiles.git"
    git remote set-url --push origin "git@github.com:$github_user/dotfiles.git"
    git fetch -q origin
    rm -f .bashrc .bash_profile
    git checkout origin/master -b master >/dev/null 2>&1
    ~/bin/cfg-install
    ~/bin/cfg-update

fi

#---------------------------------------
# root dotfiles
#---------------------------------------

if [ $UID -ne 0 ]; then
    sudo -s <<END
        # On Ubuntu, sudo sets $HOME to /home/vagrant not /root
        HOME=~root

        if [ ! -d \$HOME/.git ]; then
            echo "Installing dotfiles in \$HOME..."
            cd \$HOME
            git init -q
            git remote add origin "git://github.com/$github_user/dotfiles.git"
            git remote set-url --push origin "git@github.com:$github_user/dotfiles.git"
            git fetch -q origin
            rm -f .bashrc .bash_profile
            git checkout origin/master -b master >/dev/null 2>&1
            ~/bin/cfg-install
            ~/bin/cfg-update
        fi
END

    # Allow SSH access to the root user
    if [ -n "$public_key" -a -f "$public_key" ]; then
        sudo cp -f "$public_key" ~root/.ssh/authorized_keys
    fi
fi
