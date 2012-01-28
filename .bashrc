# Configuration
enable_sudo=0
umask_user=007
umask_root=022
www_dir=

if [ -f ~/.bashrc_config ]; then
    source ~/.bashrc_config
fi

# All files are read-write by me and my group but not anyone else
if [ `id -u` -eq 0 ]
then
    umask $umask_root
else
    umask $umask_user
fi

# Add my own bin directories to the path
export PATH="$HOME/local/bin:$HOME/bin:$HOME/opt/git-extras/bin:$HOME/opt/drush:$PATH"

# Use my favourite programs
export PAGER=less
export VISUAL=vim
export EDITOR=vim

# Don't do the rest of these when using SCP, only an SSH terminal
if [ "$TERM" != "dumb" -a -z "$BASH_EXECUTION_STRING" ]; then

    # Use the complete version of Vim on Windows instead of the cut down version
    # that's included with Git Bash
    for myvim in \
        "/c/Program Files (x86)/Vim/vim73/vim.exe" \
        "/c/Program Files/Vim/vim73/vim.exe";
    do
        if [ -f "$myvim" ]; then
            export VISUAL="$myvim"
            export EDITOR="$myvim"
            alias vim="\"$myvim\""
            alias vi="\"$myvim\""
            break
        fi
    done

    # And make gvim available too if possible
    for myvim in \
        "/c/Program Files (x86)/Vim/vim73/gvim.exe" \
        "/c/Program Files/Vim/vim73/gvim.exe";
    do
        if [ -f "$myvim" ]; then
            alias gvim="\"$myvim\""
            break
        fi
    done

    unset myvim

    # Set the titlebar & prompt to "[user@host:/full/path]\n$"
    case "$TERM" in
        xterm*)
            Titlebar="\u@\h:\$PWD"
            # Set titlebar now, before SSH key is requested, for KeePass
            echo -ne "\e]2;$USER@$(hostname -s):$PWD\a"
            ;;
        *)
            Titlebar=""
            ;;
    esac

    # FIXME: $SSH_CLIENT isn't set after using "sudo -s" - is there another way to detect SSH?
    if [ -z "$SSH_CLIENT" -o "${SSH_CLIENT:0:9}" = "127.0.0.1" ]; then
        # localhost
        HostColor="37"
    else
        # SSH
        HostColor="32;1"
    fi

    # Git/Mercurial prompt
    function vcsprompt
    {
        # Walk up the tree looking for a .git or .hg directory
        # This is faster than trying each in turn and means we get the one
        # that's closer to us if they're nested
        root=$(pwd 2>/dev/null)
        while [ ! -e "$root/.git" -a ! -e "$root/.hg" ]; do
          if [ "$root" = "" ]; then break; fi
          root=${root%/*}
        done

        if [ -e "$root/.git" ]; then
            # Git
            relative=${PWD#$root}
            if [ "$relative" != "$PWD" ]; then
                echo -en "$root\e[36;1m$relative"
                #         ^yellow  ^aqua
            else
                echo -n $PWD
                #       ^yellow
            fi

            # Show the branch name / tag / id
            branch=`git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
            if [ -n "$branch" -a "$branch" != "(no branch)" ]; then
                echo -e "\e[30;1m on \e[35;1m$branch \e[0m(git)\e[30;1m"
                #        ^grey       ^pink           ^light grey  ^ grey
            else
                tag=`git describe --always 2>/dev/null`
                if [ -z "$tag" ]; then
                    tag="(unknown)"
                fi
                echo -e "\e[30;1m at \e[35;1m$tag \e[0m(git)\e[30;1m"
                #        ^grey       ^pink        ^light grey  ^ grey
            fi
        elif [ -e "$root/.hg" ]; then
            HgPrompt=`hg prompt "{root}@@@\e[30;1m on \e[35;1m{branch} \e[0m(hg)\e[30;1m" 2>/dev/null`
            #                             ^grey       ^pink            ^light grey  ^ grey
            if [ $? -eq 0 ]; then
                # A bit of hackery so we don't have to run hg prompt twice (it's slow)
                root=${HgPrompt/@@@*}
                prompt=${HgPrompt/*@@@}
                relative=${PWD#$root}
                echo -e "$root\e[0;1m$relative$prompt"
                #        ^yellow     ^white
            else
                # Probably hg prompt isn't installed
                echo $PWD
            fi
        else
            # No .git or .hg found
            echo $PWD
        fi
    }

    # Function to update the prompt with a given message (makes it easier to distinguish between different windows)
    function MSG
    {
        # Display the provided message above the prompt and in the titlebar
        if [ -n "$*" ]; then
            MessageCode="\e[35;1m================================================================================\n $*\n================================================================================\e[0m\n"
            TitlebarCode="\[\e]2;[$*] $Titlebar\a\]"
        else
            MessageCode=
            TitlebarCode="\[\e]2;$Titlebar\a\]"
        fi

        # If changing the titlebar is not supported, remove that code
        if [ -z "$Titlebar" ]; then
            TitlebarCode=
        fi

        # Set the prompt
        PS1="${TitlebarCode}\n"                 # Titlebar (see above)
        PS1="${PS1}${MessageCode}"              # Message (see above)
        PS1="${PS1}\[\e[30;1m\]["               # [                             Grey
        PS1="${PS1}\[\e[31;1m\]\u"              # Username                      Red
        PS1="${PS1}\[\e[30;1m\]@"               # @                             Grey
        PS1="${PS1}\[\e[${HostColor}m\]\h"      # Hostname                      Green/Grey
        PS1="${PS1}\[\e[30;1m\]:"               # :                             Grey
        PS1="${PS1}\[\e[33;1m\]\`vcsprompt\`"   # Working directory / Git / Hg  Yellow
        PS1="${PS1}\[\e[30;1m\]]"               # ]                             Grey
        PS1="${PS1}\[\e[1;35m\]\$KeyStatus"     # SSH key status                Pink
        PS1="${PS1}\n"                          # (New line)
        PS1="${PS1}\[\e[31;1m\]\\\$"            # $                             Red
        PS1="${PS1}\[\e[0m\] "
    }

    # Default to prompt with no message
    MSG

    # For safety!
    alias cp='cp -i'
    alias mv='mv -i'
    alias rm='rm -i'

    # Easier undoing!
    # (Not perfect because it doesn't cope with moving a file to a directory or with options but still...)
    function umv {
        mv ${2%/} ${1%/}
    }

    # Various versions of `ls`
    alias ls='ls -hF --color=always'
    alias ll='ls -hFl --color=always'
    alias la='ls -hFA --color=always'
    alias lla='ls -hFlA --color=always'

    function l {
        if [ -z "$*" ]; then
            c .
        else
            ls -hF --color=always $@
        fi
    }

    # Grep with colour and use pager
    # Note: This has to be a script not a function so it can detect a pipe
    # But the script cannot be called "grep", because that gets called by scripts
    # So we have a function "grep" calling a script "grep-less"
    function grep {
        grep-less "$@"
    }

    # If output fits on one screen, don't use less
    export LESS=FRSX

    # Unset the colours that are sometimes set (e.g. Joshua)
    export LS_COLORS=

    # md = mkdir; cd
    function md {
        mkdir "$1" && cd "$1"
    }

    # c = cd; ls
    function c {

        # cd to the first argument
        if [ "$1" = "" ]; then
            # If none then go to ~ like cd does
            cd || return
        elif [ "$1" != "." ]; then
            # If "." don't do anything, so that "cd -" still works
            # Don't output the path as I'm going to anyway (done by "cd -" and cdspell)
            cd "$1" >/dev/null || return
        fi

        # Remove that argument
        shift

        # Output the path
        echo
        echo -en "\e[4;1m"
        echo $PWD
        echo -en "\e[0m"

        # Then pass the rest to ls (just in case we have any use for that!)
        ls -h --color=always "$@"

    }

    export -f c

    # u = up
    alias u='c ..'
    alias uu='c ../..'
    alias uuu='c ../../..'
    alias uuuu='c ../../../..'
    alias uuuuu='c ../../../../..'
    alias uuuuuu='c ../../../../../..'

    # b = back
    alias b='c -'

    # various tools
    alias g='grep -ir'
    alias h='head'
    alias t='tail'

    # I keep typing this wrong:
    alias chmox='chmod'

    # chmod_g+s
    function chmod_g+s {
        if [ -z "$1" ]; then
            find . -type d -exec chmod g+s '{}' \;
        else
            find "$1" -type d -exec chmod g+s '{}' \;
        fi
    }

    # realpath
    # TODO: What's the correct way to do this without PHP?
    function realpath {
        if [ -n "$1" ]; then
            path="$1"
        else
            path="."
        fi
        echo "<?php echo realpath('$path') ?>" | php -q
        echo
    }

    # pwgen*
    alias pwgen15="pwgen -c -n -y -B 15 1"
    alias pwgen20="pwgen -c -n -y -B 20 1"

    # hg
    alias hgst="hg st"
    alias mq='hg -R $(hg root)/.hg/patches'

    # rvm
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

    # rails
    alias guard="bundle exec guard"

    # ack (Debian renames to ack-grep)
    if which ack-grep >/dev/null 2>&1; then
        alias ack="ack-grep"
    fi

    # Remember the last directory visited
    function cd {
        command cd "$@" && pwd > ~/.bash_lastdirectory
    }

    # Go to my home directory by default
    command cd

    # Go to the stored directory now, if possible
    if [ -f ~/.bash_lastdirectory ]; then
        # Throw away errors about that directory not existing (any more)
        command cd "`cat ~/.bash_lastdirectory`" 2>/dev/null
    fi

    # Detect typos in the cd command
    shopt -s cdspell

    # Ignore case
    set completion-ignore-case on

    # Don't expand !! and friends
    # (Because I don't use it and because `echo "Hello!"` fails and `echo "Hello\!"` leaves in the \!)
    # Source: http://chris-lamb.co.uk/2007/10/09/top-10-interactive-shell-anti-patterns/
    # (Yes, I learned this command from a post telling me NOT to do it!)
    set +H

    # Start typing then use Up/Down to see *matching* history items
    bind '"\e[A":history-search-backward'
    bind '"\e[B":history-search-forward'

    # Don't store duplicate entries in history
    export HISTIGNORE="&"

    # Save history immediately, so multiple terminals don't overwrite each other!
    shopt -s histappend
    PROMPT_COMMAND='history -a'

    # Disable Ctrl-S = Stop output (except it's not available in Git's Cygwin)
    if which stty >/dev/null; then
        stty -ixon
    fi

    # /home/www shortcuts
    if [ -n "$www_dir" ]; then
        alias cw="c $www_dir"
    fi

    # sudo shortcuts
    if [ $enable_sudo -eq 1 ]; then

        # sudo
        alias s='sudo'
        alias se.="se ."

        # Versions of 'sudo ls'
        alias sl='sudo ls -h --color=always'
        alias sls='sudo ls -h --color=always'
        alias sll='sudo ls -hl --color=always'
        alias sla='sudo ls -hA --color=always'
        alias slla='sudo ls -hlA --color=always'

        # apt-get
        alias agi='sudo apt-get install'
        alias agr='sudo apt-get remove'
        alias agar='sudo apt-get autoremove'
        alias agu='sudo apt-get update && sudo apt-get upgrade'
        alias acs='apt-cache search'
        alias acsh='apt-cache show'

        # Poweroff and reboot need sudo
        alias poweroff='sudo poweroff; exit'
        alias pow='sudo poweroff; exit'
        alias shutdown='sudo poweroff; exit'
        alias reboot='sudo reboot; exit'

        # Add sbin folder to my path so they can be auto-completed
        PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"

        # Additional safety checks
        function sudo {
            if [ "$1" = "cp" -o "$1" = "mv" -o "$1" = "rm" ]; then
                exe="$1"
                shift
                command sudo "$exe" -i "$@"
            else
                command sudo "$@"
            fi
        }

    fi

fi # $TERM != "dumb"

# Prevent errors when MSG is set in .bashrc_local
if [ "$TERM" = "dumb" -a -z "$BASH_EXECUTION_STRING" ]; then
    function MSG {
        : Do nothing
    }
fi

# Custom settings for this machine/account
if [ -f ~/.bashrc_local ]; then
    source ~/.bashrc_local
fi

# *After* doing the rest, show the current directory contents
# But only do this once - gitolite seems to load this file twice!
if [ "$TERM" != "dumb" -a -z "$BASH_EXECUTION_STRING" ]; then
    l
fi

# Git Cygwin loads this file *and* .bash_profile so set a flag to tell
# .bash_profile not to load .bashrc again
BASHRC_DONE=1
