if $HAS_TERMINAL; then

    # Enable dynamic $COLUMNS and $LINES variables
    shopt -s checkwinsize

    # Get hostname
    prompthostname() {
        if [ -f ~/.hostname ]; then
            # Custom hostname
            cat ~/.hostname
        elif $WINDOWS; then
            # Titlecase hostname on Windows
            #hostname | sed 's/\(.\)\(.*\)/\u\1\L\2/'
            # Lowercase hostname on Windows
            hostname | tr '[:upper:]' '[:lower:]'
        else
            # FQDN hostname on Linux
            hostname -f
        #elif [ "$1" = "init" ]; then
        #    hostname -s
        #else
        #    echo '\H'
        fi
    }

    # Set the titlebar & prompt to "[user@host:/full/path]\n$"
    case "$TERM" in
        xterm*|screen*|cygwin*)
            Titlebar="\u@$(prompthostname):\$PWD"
            # Set titlebar now, before SSH key is requested, for KeePass
            echo -ne "\033]2;${USER:-$USERNAME}@$(prompthostname init):$PWD\a"
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
            # Note: Using 'command git' to bypass 'hub' which is slightly slower and not needed here
            branch=`command git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
            if [ -n "$branch" -a "$branch" != "(no branch)" ]; then
                echo -e "\033[30;1m on \033[35;1m$branch\033[30;1m"
                #        ^grey       ^pink           ^light grey
            else
                tag=`command git describe --always 2>/dev/null`
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

    # Python virtualenvwrapper prompt
    venvprompt()
    {
        if [ -n "$VIRTUAL_ENV" ]; then
            echo -e " ENV=${VIRTUAL_ENV##*/}"
        fi
    }

    # Function to update the prompt with a given message (makes it easier to distinguish between different windows)
    # TODO: Tidy this up, especially the variable names!
    MSG()
    {
        # Determine prompt colour
        if [ "${1:0:2}" = "--" ]; then
            # e.g. --live
            PromptType="${1:2}"
            shift
        else
            PromptType="$prompt_type"
        fi

        if [ "$PromptType" = "dev" ]; then
            prompt_color='30;42' # Green (black text)
        elif [ "$PromptType" = "live" ]; then
            prompt_color='41;1' # Red
        elif [ "$PromptType" = "staging" ]; then
            prompt_color='30;43' # Yellow (black text)
        elif [ "$PromptType" = "special" ]; then
            prompt_color='44;1' # Blue
        else
            prompt_color='45;1' # Pink
        fi

        # Display the provided message above the prompt and in the titlebar
        if [ -n "$*" ]; then
            PromptMessage="$*"
        elif [ -n "$prompt_default" ]; then
            PromptMessage="$prompt_default"
        elif ! $DOCKER && [ $EUID -eq 0 ]; then
            PromptMessage="Logged in as ROOT!"
            prompt_color='41;1' # Red
        else
            PromptMessage=""
        fi

        if [ -n "$PromptMessage" ]; then
            # Lots of escaped characters here to prevent this being executed
            # until the prompt is displayed, so it can adjust when the window
            # is resized
            spaces="\$(printf '%*s\n' \"\$((\$COLUMNS-${#PromptMessage}-1))\" '')"
            MessageCode="\033[${prompt_color}m $PromptMessage$spaces\033[0m\n"
            TitlebarCode="\[\033]2;[$PromptMessage] $Titlebar\a\]"
        else
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
        PS1="${PS1}\[\033[30;1m\]["                 # [                             Grey
        PS1="${PS1}\[\033[31;1m\]\u"                # Username                      Red
        PS1="${PS1}\[\033[30;1m\]@"                 # @                             Grey
        PS1="${PS1}\[\033[32;1m\]$(prompthostname)" # Hostname                      Green
        PS1="${PS1}\[\033[30;1m\]:"                 # :                             Grey
        # Note: \$(...) doesn't work in Git for Windows (4 Mar 2018)
        PS1="${PS1}\[\033[33;1m\]\`vcsprompt\`"     # Working directory / Git / Hg  Yellow
        PS1="${PS1}\[\033[30;1m\]\`venvprompt\`"    # Python virtual env            Grey
        PS1="${PS1}\[\033[30;1m\] at "              # at                            Grey
        PS1="${PS1}\[\033[37;0m\]\D{%T}"            # Time                          Light grey
        #PS1="${PS1}\[\033[30;1m\] on "              # on                            Grey
        #PS1="${PS1}\[\033[30;1m\]\D{%d/%m/%Y}"      # Date                          Light grey
        PS1="${PS1}\[\033[30;1m\]]"                 # ]                             Grey
        PS1="${PS1}\[\033[1;35m\]\$KeyStatus"       # SSH key status                Pink
        PS1="${PS1}\n"                              # (New line)
        PS1="${PS1}\[\033[31;1m\]\\\$"              # $                             Red
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
