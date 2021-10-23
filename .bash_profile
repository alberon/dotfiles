#
# This file is executed every time Bash is loaded, even if it is NOT an interactive session
#
# Also see: .bashrc
#

#===============================================================================
# Setup
#===============================================================================

#---------------------------------------
# Safety checks
#---------------------------------------

# Only load this file once
[[ -n $BASH_PROFILE_SOURCED ]] && return
BASH_PROFILE_SOURCED=true


#---------------------------------------
# Environment checks
#---------------------------------------

# $USER is not set inside Docker
if [[ -z ${USER:-} ]]; then
    export USER=$(whoami)
fi

#---------------------------------------
# Path
#---------------------------------------

# Note: The ones lower down take precedence
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

PATH="$HOME/go/bin:$PATH"
PATH="$HOME/.rvm/bin:$PATH"
PATH="$HOME/.yarn/bin:$PATH"

PATH="$HOME/.config/composer/vendor/bin:$PATH"
PATH="$HOME/.composer/vendor/bin:$PATH"
PATH="$HOME/.composer/packages/vendor/bin:$PATH"

PATH="$HOME/.bin:$PATH"

if is-wsl; then
    # Note: Can't use aliases because they interfere with _complete_alias
    PATH="$HOME/.bin/windows:$PATH"
fi

# For tab completion with sudo
PATH="$PATH:/usr/local/sbin"
PATH="$PATH:/usr/sbin"
PATH="$PATH:/sbin"

export PATH


#---------------------------------------
# Umask
#---------------------------------------

if [[ $(umask) = 0000 ]]; then
    if is-root-user; then
        umask 022
    else
        umask 002
    fi
fi


#===============================================================================
# Settings
#===============================================================================

export EDITOR='vim'
export GEDITOR="$EDITOR"
export LESS='FRX'
export LS_COLORS='rs=0:fi=01;37:di=01;33:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32'
export PAGER='less'
export PGDATABASE='postgres'
export VISUAL="$EDITOR"

if [[ -z $DISPLAY ]]; then
    if is-wsl 1 || is-cygwin; then
        export DISPLAY='localhost:0'
    elif is-wsl 2; then
        # https://blog.nimamoh.net/wsl2-and-vcxsrv/
        export DISPLAY="$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0"
    fi
fi

# Stop Perl complaining on cPanel servers
# I did set in MinTTY, but it's not picked up
# Using en_US instead of en_GB to stop Vim and less complaining
if [[ ${LANG:-} = 'C.UTF-8' ]]; then
    export LANG='en_US.UTF-8'
fi

#if [ -z "$XAUTHORITY" ]; then
#    export XAUTHORITY="$HOME/.Xauthority"
#fi


#---------------------------------------
# SSH agent
#---------------------------------------

source ~/.bash/color.bash

if is-wsl 1; then

    # wsl-ssh-pageant - https://github.com/benpye/wsl-ssh-pageant
    if [[ ! -f ~/.ssh/wsl-ssh-pageant.exe ]]; then
        echo
        color lblue 'Downloading wsl-ssh-pageant...'
        curl -L 'https://github.com/benpye/wsl-ssh-pageant/releases/download/20201121.2/wsl-ssh-pageant-amd64.exe' > ~/.ssh/wsl-ssh-pageant.exe
    fi

    temp=$(wsl-temp-path)
    export SSH_AUTH_SOCK="$temp/wsl-ssh-pageant.sock"

    if [[ $(tasklist.exe /FI "IMAGENAME EQ wsl-ssh-pageant.exe" /FO CSV | tail +2 | wc -l) -eq 0 ]]; then
        rm -f "$temp/wsl-ssh-pageant.exe" "$SSH_AUTH_SOCK" 2>/dev/null && \
            cp ~/.ssh/wsl-ssh-pageant.exe "$temp/wsl-ssh-pageant.exe"

        # This is a bit convoluted, but if wsl-ssh-pageant.exe is started as a
        # sub-process then as soon as WSL is closed it jumps to 100% CPU. This
        # way it runs outside the WSL process tree, so it keeps working.
        temp_win=$(wslpath -w "$temp")
        cmd.exe /c start /b "$temp_win\\wsl-ssh-pageant.exe" --force --wsl "$temp_win\\wsl-ssh-pageant.sock" &>/dev/null
    fi

elif is-wsl 2; then

    # wsl2-ssh-pageant - https://github.com/BlackReloaded/wsl2-ssh-pageant
    if [[ ! -f ~/.ssh/wsl2-ssh-pageant.exe ]]; then
        echo
        color lblue 'Downloading wsl2-ssh-pageant...'
        curl -L 'https://github.com/BlackReloaded/wsl2-ssh-pageant/releases/download/v1.3.0/wsl2-ssh-pageant.exe' > ~/.ssh/wsl2-ssh-pageant.exe
    fi

    if [[ -f ~/.ssh/wsl2-ssh-pageant.exe ]]; then
        chmod +x ~/.ssh/wsl2-ssh-pageant.exe
        export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"
        if ! command -v socat >/dev/null; then
            echo
            color lblue 'Installing socat for wsl2-ssh-pageant...'
            sudo apt-get install socat
        fi
        if ! ss -a | grep -q $SSH_AUTH_SOCK; then
            rm -f $SSH_AUTH_SOCK
            setsid --fork nohup socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:$HOME/.ssh/wsl2-ssh-pageant.exe &>/dev/null
        fi
    fi

elif is-cygwin; then

    # ssh-pageant - https://github.com/cuviper/ssh-pageant
    if [[ ! -f ~/.ssh/ssh-pageant.exe ]]; then
        echo
        color lblue 'Downloading ssh-pageant...'
        wget -O - https://github.com/cuviper/ssh-pageant/archive/refs/tags/v1.4-prebuilt-cygwin64.tar.gz | tar -zxO ssh-pageant-1.4-prebuilt-cygwin64/ssh-pageant.exe > ~/.ssh/ssh-pageant.exe
        chmod +x ~/.ssh/ssh-pageant.exe
    fi

    eval $(~/.ssh/ssh-pageant.exe -r -a "$HOME/.ssh/ssh_auth_sock")

else

    # Any other platform
    # Workaround for losing SSH agent connection when reconnecting tmux
    link="$HOME/.ssh/ssh_auth_sock"
    if [[ $SSH_AUTH_SOCK != $link ]] && [[ -S $SSH_AUTH_SOCK ]]; then
        ln -nsf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
    fi
    export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"

fi


#---------------------------------------
# SSH config
#---------------------------------------

# Dynamically generate some of the SSH config
(
    if is-cygwin || is-gitforwindows; then
        echo '# ControlMaster is not supported in Cygwin / Git for Windows'
        echo '# https://stackoverflow.com/a/21439862/167815'
    else
        echo 'Host *'
        echo '    # Reuse connections'
        echo '    ControlMaster auto'
        echo '    ControlPath ~/.ssh/control-master-%r@%h:%p'
        echo '    ControlPersist 10s'
    fi

    echo
    echo '# vim:ft=sshconfig'
) > ~/.ssh/config_dynamic


#---------------------------------------
# Custom settings / functions
#---------------------------------------

# Personal settings, for use in forks
[[ -f ~/.bash_profile_personal ]] && source ~/.bash_profile_personal

# Local settings, not committed to Git
[[ -f ~/.bash_profile_local ]] && source ~/.bash_profile_local


#===============================================================================
# Interactive shells
#===============================================================================

# Use .bashrc for interactive shell settings
source ~/.bashrc
