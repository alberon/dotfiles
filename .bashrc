# Configuration
auto_screen=0
auto_unlock=1
enable_sudo=0
use_vi_for_vim=0
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

# Add my own bin directory to the path
export PATH="~/local/bin:~/bin:$PATH"

# Use my favourite programs
export PAGER=less

if [ $use_vi_for_vim -eq 1 ]; then
    export VISUAL=vi
    export EDITOR=vi
    alias vim='vi'
else
    export VISUAL=vim
    export EDITOR=vim
fi

# Don't do the rest of these when using SCP, only an SSH terminal
if [ "$TERM" != "dumb" ]; then
    
    if [ $auto_screen -eq 1 ]; then
        # Automatically run `screen`
        # http://taint.org/wk/RemoteLoginAutoScreen
        # If we're coming from a remote SSH connection, in an interactive session
        # then automatically put us into a screen(1) session. Only try once
        # -- if $STARTED_SCREEN is set, don't try it again, to avoid looping
        # if screen fails for some reason.
        if [ "$PS1" != "" -a "${STARTED_SCREEN:-x}" = x -a "${SSH_TTY:-x}" != x ]
        then
            export STARTED_SCREEN=1
            #sleep 1
            screen -RR -t "`whoami`@$HOSTNAME" && exit 0
            # normally execution of this script ends here...
            echo "Screen failed! continuing with normal bash startup"
        fi
    fi
    
    # Set the titlebar & prompt to "[user@host:id ~/path date, time (x jobs)]\n$"
    #export PS1="\e]2;\u@\h:\l \w \d, \@ (\j jobs)\a\n[\e[31;1m\u\e[0m@\e[32;1m\h\e[0m:\e[34;1m\l\e[0m \e[33;1m\w\e[0m \e[35;1m\d, \@\e[0m \e[36;1m(\j jobs)\e[0m]\n\[\e[31;1m\]\$\[\e[0m\] "
    
    # Set the titlebar & prompt to "[user@host:/full/path]\n$"
    case "$TERM" in
        xterm*) Titlebar="\[\e]2;\u@\h:\$PWD\a\]" ;;
        *) Titlebar="" ;;
    esac
    
    # FIXME: $SSH_CLIENT isn't set after using "sudo -s" - is there another way to detect SSH?
    if [ -z "$SSH_CLIENT" -o "${SSH_CLIENT:0:9}" = "127.0.0.1" ]; then
        # localhost
        HostColor="37"
    else
        # SSH
        HostColor="32;1"
    fi
    
    PS1="${Titlebar}\n\e[0m[\[\e[31;1m\]\u\[\e[0m\]@\[\e[${HostColor}m\]\h\[\e[0m\]:\[\e[33;1m\]\$PWD\[\e[0m\]]\e[1;35m\$KeyStatus\n\[\e[31;1m\]\$\[\e[0m\] "

    # Reload .bashrc when updated
    alias reload-bashrc='. ~/.bashrc'
    
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
    # Note: This has to be a function so it can detect a pipe
    # But it cannot be called "grep" because that gets called by shell scripts as well as interactively
    function grep {
        grep-less "$@"
    }
    
    # If output fits on one screen, don't use less
    export LESS=FRSX
    
    # Unset the colours that are sometimes set (e.g. Joshua)
    export LS_COLORS=
    
    # cls = clear
    alias cls='clear'
    
    # e. = e . (browse directory in vim)
    alias e.='e .'
    
    # meld (backgrounded & don't spit out all the ALSA errors when there's no sound card)
    #function meld {
    #  command meld "$@" 3>&1 1>&2 2>&3 | grep -v "ALSA lib " 3>&1 1>&2 2>&3 &
    #}
    
    # mkcd/md = mkdir; cd
    function mkcd {
        mkdir "$1" && cd "$1"
    }
    
    function md {
        mkdir "$1" && cd "$1"
    }
    
    # c = cd; ls
    function c {
        
        # If it's a file, I probably meant to type 'e' not 'c'
        if [ -n "$1" -a -f "$1" ]; then
            read -p "That is a file - open in editor instead? [Y/n] " reply
            case $reply in
                N*|n*) return ;;
                *) e "$@"; return ;;
            esac
        fi
        
        # cd to the first argument
        if [ "$1" = "" ]; then
            # If none then go to ~ like cd does
            cd
        elif [ "$1" != "." ]; then
            # If "." don't do anything, so that "cd -" still works
            # Don't output the path as I'm going to anyway (done by "cd -" and cdspell)
            cd "$1" >/dev/null
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
    
    # d = e or c (note placement on keyboard between the two!)
    function d {
        if [ -d "$1" ]; then
            c "$@"
        elif [ -f "$1" ]; then
            e "$@"
        else
            echo "Can't find \"$1\"!" >&2
        fi
    }
    
    # various tools
    alias g='grep'
    alias h='head'
    alias t='tail'
    
    # tar
    alias tart='tar tf'
    alias tarx='tar xf'

    # mutt (mail)
    alias mutt2='mutt -f ~/mbox'

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
    
    # Remember the last directory visited
    function cd {
        command cd "$@"
        pwd > ~/.bash_lastdirectory
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
    
    # Disable Ctrl-S = Stop output
    stty -ixon
    
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
        
        # Add sbin folder to my path to make it easier to find the programs
        PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"
        
    fi
    
    # Make sure ssh-agent is loaded (for this user) - do this now so it's available for `mkkey`
    if [ -z "$SSH_AGENT_PID" ] || (! kill -0 "$SSH_AGENT_PID" 2>/dev/null)
    then
        
        # Try the stored settings instead
        if [ -f ~/.ssh/environment-$HOSTNAME ]
        then
            source ~/.ssh/environment-$HOSTNAME
        fi
        
        if [ -z "$SSH_AGENT_PID" ] || (! kill -0 "$SSH_AGENT_PID" 2>/dev/null)
        then
            
            # Store keys for at most 16 hours
            if [ ! -d ~/.ssh ]; then
                mkdir ~/.ssh
                chmod 700 ~/.ssh
            fi
            ssh-agent -t 57600 | head -2 > ~/.ssh/environment-$HOSTNAME
            source ~/.ssh/environment-$HOSTNAME
            
        fi
        
    fi
    
    # Statuses for locked/unlocked
    KeyStatusLocked="-SSH Keys Locked-"
    KeyStatusUnlocked=""
    
    # Unlock keys
    function unlock {
        
        # Make it clear which server is asking for the password!
        echo
        echo -e "\e[31;1mYou are connected to $HOSTNAME\e[33;1m"
        
        # Allow different files to be used
        if [ -n "$1" -a "$1" != "AUTO" ]
        then
            file="$1"
        elif [ -f ~/.ssh/id_dsa ]
        then
            file="$HOME/.ssh/id_dsa"
        else
            echo -e "\e[32;1mNo SSH keys are available.\e[0m"
        fi
        
        # Make sure the key is loaded (assume there is only one - any more can be added manually)
        if [ "`ssh-add -l`" != "The agent has no identities." ]; then
            
            # Already unlocked
            echo -e "\e[32;1mSSH keys are unlocked.\e[0m"
            KeyStatus=$KeyStatusUnlocked
            
        elif [ "$1" = "AUTO" -a $auto_unlock -ne 1 ]; then
            
            # Automatic unlock disabled
            echo -e "\e[30;1mSSH keys are locked.\e[0m"
            KeyStatus=$KeyStatusLocked
            
        else
            
            # Unlock now
            
            # Trap Ctrl-C
            trapped=0
            trap 'trapped=1' SIGINT
            
            # Store keys for at most 16 hours
            ssh-add -t 57600 "$file"
            
            if [ $? -eq 0 -a $trapped -eq 0 ]; then
                echo -e "\e[32;1mSSH keys are now unlocked.\e[0m"
                KeyStatus=$KeyStatusUnlocked
                return 0
            else
                echo -e "\e[30;1mCancelled. SSH keys are still locked.\e[0m"
                KeyStatus=$KeyStatusLocked
            fi
            
            # Reset trap
            trap SIGINT
            trapped=
            
        fi
        
    }
    
    # Lock keys
    function lock {
        
        # Allow different files to be used
        if [ -N "$1" ]; then
            ssh-add -d "$1"
        else
            # All
            ssh-add -D
        fi
        
        KeyStatus=$KeyStatusLocked
        
    }
    
    # Unlock default keys at login
    if [ -f ~/.ssh/id_dsa ]; then
        unlock "AUTO"
    fi
    
    # Make it easy to get the svn root of the current directory working copy
    function svnroot {
        
        # Get the root - shows an error if we're not inside a working copy
        root=`svn info | grep '^Repository Root:' | sed 's/^Repository Root: //'`
        
        # If it was found, set it and show it for confirmation
        if [ -n "$root" ]
        then
            export svn="$root"
            echo "Set \$svn to $svn"
        fi
        
    }
    
    export -f svnroot
    
    # Use Vim for highlighting svn diffs
    function svndiff {
        svn diff "$@" | e -R "+set syn=diff" -
    }
    
    # Symfony commands
    function cdsf {
        
        # Record the current dir
        cwd=`pwd`
        
        # Record the previous dir too so "cd -" still works correctly if this function fails
        cd - >/dev/null
        oldcwd=`pwd`
        cd "$cwd"
        
        # Go up the directory tree until we find the correct directory or reach /
        while [ "`pwd`" != "/" -a ! -x "./symfony" -a ! -d "./symfony" ]
        do
            cd ..
        done
        
        # Do the cd
        sfdir=`pwd`
        if [ -x "./symfony" -a ! -d "./symfony" ]
        then
            
            # Do nothing if this is the same dir we started in
            if [ "$sfdir" != "$cwd" ]
            then
                cd "$cwd"
                cd "$sfdir"
            fi
            
        else
            echo "You do not appear to be within a symfony directory" >&2
            cd "$oldcwd"
            cd "$cwd"
        fi
        
    }
    
    alias sfcd='cdsf'
    alias sfcc='sf cc'
    alias sfc='sf cc'
    
    # Twitter
    function twit {
        
        if [ -n "$*" ]; then
            
            message="$*"
            
        else
            
            # Show ruler
            echo -e "\e[35m"
            echo "#  Twitter Update - You have this much space:"
            echo "# ============================================================================================================================================"
            echo -e "\e[0m"
            
            # Input message
            read -p "> " message
            
            # Exit if nothing was entered
            if [ -z "$message" ]; then
                return
            fi
            
        fi
        
        # Work out length of message (note: wc always adds 1 for EOF)
        len=`echo "$message" | wc -c`
        len=$(($len - 1))
    
        # Confirm
        read -p "Length is $len chars; Send update now? [Y/n] " confirm
        
        case "$confirm" in
            n*|N*) return ;;
        esac
        
        # Send update
        ~/bin/blt "$message"
        
        # Download updates as a confirmation
        twitter -f
        
    }
    
    function twitter {
        latest=`~/bin/blt -c -s $@`
        if [ -n "$latest" ]; then
            echo -e "\n\e[35;1m$latest\e[0m"
        else
            echo -e "\n\e[35mNothing to report\e[0m"
        fi
    }
    
    #if [ -n "$PROMPT_COMMAND" ]; then
    #  PROMPT_COMMAND="$PROMPT_COMMAND; "
    #fi
    #
    #BLT_COMMAND='blt_latest=`$HOME/bin/blt -c`; if [ -n "$blt_latest" ]; then echo -e "\n\e[35;1m$blt_latest\e[0m"; fi;'
    #
    #PROMPT_COMMAND="$PROMPT_COMMAND$BLT_COMMAND"
    
fi # $TERM != "dumb"

# Custom settings for this machine/account
if [ -f ~/.bashrc_local ]; then
    source ~/.bashrc_local
fi

# *After* doing the rest, show the current directory contents
if [ "$TERM" != "dumb" ]; then
    l
fi
