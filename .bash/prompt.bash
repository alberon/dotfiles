if $HAS_TERMINAL; then

    function prompthostname {
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
            Titlebar="\u@\h:\$PWD"
            # Set titlebar now, before SSH key is requested, for KeePass
            echo -ne "\e]2;$USER@$(prompthostname init):$PWD\a"
            ;;
        *)
            Titlebar=""
            ;;
    esac

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
            MessageCode="\e[35;1m--------------------------------------------------------------------------------\n $*\n--------------------------------------------------------------------------------\e[0m\n"
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
        PS1="${TitlebarCode}\n"                     # Titlebar (see above)
        PS1="${PS1}${MessageCode}"                  # Message (see above)
        PS1="${PS1}\[\e[30;1m\]["                   # [                             Grey
        PS1="${PS1}\[\e[31;1m\]\u"                  # Username                      Red
        PS1="${PS1}\[\e[30;1m\]@"                   # @                             Grey
        PS1="${PS1}\[\e[32;1m\]$(prompthostname)"   # Hostname                      Green
        PS1="${PS1}\[\e[30;1m\]:"                   # :                             Grey
        PS1="${PS1}\[\e[33;1m\]\`vcsprompt\`"       # Working directory / Git / Hg  Yellow
        PS1="${PS1}\[\e[30;1m\]]"                   # ]                             Grey
        PS1="${PS1}\[\e[1;35m\]\$KeyStatus"         # SSH key status                Pink
        PS1="${PS1}\n"                              # (New line)
        PS1="${PS1}\[\e[31;1m\]\\\$"                # $                             Red
        PS1="${PS1}\[\e[0m\] "
    }

    # Default to prompt with no message
    MSG

else

    # Prevent errors when MSG is set in .bashrc_local
    function MSG {
        : Do nothing
    }

fi
