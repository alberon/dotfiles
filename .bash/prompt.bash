if $HAS_TERMINAL; then

    prompthostname() {
        if [ -f ~/.hostname ]; then
            cat ~/.hostname
        elif [ "$1" = "init" ]; then
            hostname -s
        else
            echo '\h'
        fi
    }

    # Set the titlebar & prompt to "[user@host:/full/path]\n$"
    case "$TERM" in
        xterm*)
            Titlebar="\u@$(prompthostname):\$PWD"
            # Set titlebar now, before SSH key is requested, for KeePass
            echo -ne "\033]2;$USER@$(prompthostname init):$PWD\a"
            ;;
        *)
            Titlebar=""
            ;;
    esac

    # Git/Mercurial prompt
    vcsprompt()
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
                echo -en "$root\033[36;1m$relative"
                #         ^yellow  ^aqua
            else
                echo -n $PWD
                #       ^yellow
            fi

            # Show the branch name / tag / id
            branch=`git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
            if [ -n "$branch" -a "$branch" != "(no branch)" ]; then
                echo -e "\033[30;1m on \033[35;1m$branch \033[0m(git)\033[30;1m"
                #        ^grey       ^pink           ^light grey  ^ grey
            else
                tag=`git describe --always 2>/dev/null`
                if [ -z "$tag" ]; then
                    tag="(unknown)"
                fi
                echo -e "\033[30;1m at \033[35;1m$tag \033[0m(git)\033[30;1m"
                #        ^grey       ^pink        ^light grey  ^ grey
            fi
        elif [ -e "$root/.hg" ]; then
            HgPrompt=`hg prompt "{root}@@@\033[30;1m on \033[35;1m{branch} \033[0m(hg)\033[30;1m" 2>/dev/null`
            #                             ^grey       ^pink            ^light grey  ^ grey
            if [ $? -eq 0 ]; then
                # A bit of hackery so we don't have to run hg prompt twice (it's slow)
                root=${HgPrompt/@@@*}
                prompt=${HgPrompt/*@@@}
                relative=${PWD#$root}
                echo -e "$root\033[0;1m$relative$prompt"
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
    MSG()
    {
        # Display the provided message above the prompt and in the titlebar
        if [ -n "$*" ]; then
            PromptMessage="$1"
            MessageCode="\033[35;1m--------------------------------------------------------------------------------\n $*\n--------------------------------------------------------------------------------\033[0m\n"
            TitlebarCode="\[\033]2;[$*] $Titlebar\a\]"
        else
            PromptMessage=
            MessageCode=
            TitlebarCode="\[\033]2;$Titlebar\a\]"
        fi

        # If changing the titlebar is not supported, remove that code
        if [ -z "$Titlebar" ]; then
            TitlebarCode=
        fi

        # Set the prompt
        PS1="${TitlebarCode}\n"                     # Titlebar (see above)
        PS1="${PS1}${MessageCode}"                  # Message (see above)
        PS1="${PS1}\[\033[30;1m\]["                   # [                             Grey
        PS1="${PS1}\[\033[31;1m\]\u"                  # Username                      Red
        PS1="${PS1}\[\033[30;1m\]@"                   # @                             Grey
        PS1="${PS1}\[\033[32;1m\]$(prompthostname)"   # Hostname                      Green
        PS1="${PS1}\[\033[30;1m\]:"                   # :                             Grey
        PS1="${PS1}\[\033[33;1m\]\`vcsprompt\`"       # Working directory / Git / Hg  Yellow
        PS1="${PS1}\[\033[30;1m\]]"                   # ]                             Grey
        PS1="${PS1}\[\033[1;35m\]\$KeyStatus"         # SSH key status                Pink
        PS1="${PS1}\n"                              # (New line)
        PS1="${PS1}\[\033[31;1m\]\\\$"                # $                             Red
        PS1="${PS1}\[\033[0m\] "
    }

    # Default to prompt with no message
    MSG

else

    # Prevent errors when MSG is set in .bashrc_local
    MSG() {
        : Do nothing
    }

fi
