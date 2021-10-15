if $HAS_TERMINAL; then

    # Enable dynamic $COLUMNS and $LINES variables
    shopt -s checkwinsize

    # Get hostname
    prompthostname() {
        if [ -f ~/.hostname ]; then
            # Custom hostname
            cat ~/.hostname
        elif $WINDOWS || $WSL; then
            # Titlecase hostname on Windows (no .localdomain)
            #hostname | sed 's/\(.\)\(.*\)/\u\1\L\2/'
            # Lowercase hostname on Windows (no .localdomain)
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

  ######################################################################################################################
  # All the git_prompt_* stuff is basically just recycled https://github.com/twolfson/sexy-bash-prompt
  # renamed to give it more meaningful context here
  ######################################################################################################################
  # Set up symbols
  git_prompt_synced_symbol=""
  git_prompt_dirty_synced_symbol="*"
  git_prompt_unpushed_symbol="△"
  git_prompt_dirty_unpushed_symbol="▲"
  git_prompt_unpulled_symbol="▽"
  git_prompt_dirty_unpulled_symbol="▼"
  git_prompt_unpushed_unpulled_symbol="⬡"
  git_prompt_dirty_unpushed_unpulled_symbol="⬢"

  function git_prompt_get_git_progress() {
    # Detect in-progress actions (e.g. merge, rebase)
    # https://github.com/git/git/blob/v1.9-rc2/wt-status.c#L1199-L1241
    git_dir="$(git rev-parse --git-dir)"

    # git merge
    if [[ -f "$git_dir/MERGE_HEAD" ]]; then
      echo -n " [merge]"
    elif [[ -d "$git_dir/rebase-apply" ]]; then
      # git am
      if [[ -f "$git_dir/rebase-apply/applying" ]]; then
        echo -n " [am]"
      # git rebase
      else
        echo -n " [rebase]"
      fi
    elif [[ -d "$git_dir/rebase-merge" ]]; then
      # git rebase --interactive/--merge
      echo -n " [rebase]"
    elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
      # git cherry-pick
      echo -n " [cherry-pick]"
    fi
    if [[ -f "$git_dir/BISECT_LOG" ]]; then
      # git bisect
      echo -n " [bisect]"
    fi
    if [[ -f "$git_dir/REVERT_HEAD" ]]; then
      # git revert --no-commit
      echo -n " [revert]"
    fi
  }

  function git_prompt_get_git_status() {
    # Grab the git dirty and git behind
    dirty_branch="$(git_prompt_parse_git_dirty)"
    branch_ahead="$(git_prompt_parse_git_ahead)"
    branch_behind="$(git_prompt_parse_git_behind)"

    # Iterate through all the cases and if it matches, then echo
    if [[ "$dirty_branch" == 1 && "$branch_ahead" == 1 && "$branch_behind" == 1 ]]; then
      echo "$git_prompt_dirty_unpushed_unpulled_symbol"
    elif [[ "$branch_ahead" == 1 && "$branch_behind" == 1 ]]; then
      echo "$git_prompt_unpushed_unpulled_symbol"
    elif [[ "$dirty_branch" == 1 && "$branch_ahead" == 1 ]]; then
      echo "$git_prompt_dirty_unpushed_symbol"
    elif [[ "$branch_ahead" == 1 ]]; then
      echo "$git_prompt_unpushed_symbol"
    elif [[ "$dirty_branch" == 1 && "$branch_behind" == 1 ]]; then
      echo "$git_prompt_dirty_unpulled_symbol"
    elif [[ "$branch_behind" == 1 ]]; then
      echo "$git_prompt_unpulled_symbol"
    elif [[ "$dirty_branch" == 1 ]]; then
      echo "$git_prompt_dirty_synced_symbol"
    else # clean
      echo "$git_prompt_synced_symbol"
    fi
  }

  function git_prompt_get_git_branch() {
    # On branches, this will return the branch name
    # On non-branches, (no branch)
    ref="$(git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///')"
    if [[ "$ref" != "" ]]; then
      echo "$ref"
    else
      echo "(no branch)"
    fi
  }

  git_prompt_is_branch1_behind_branch2 () {
    # $ git log origin/master..master -1
    # commit 4a633f715caf26f6e9495198f89bba20f3402a32
    # Author: Todd Wolfson <todd@twolfson.com>
    # Date:   Sun Jul 7 22:12:17 2013 -0700
    #
    #     Unsynced commit

    # Find the first log (if any) that is in branch1 but not branch2
    first_log="$(git log $1..$2 -1 2> /dev/null)"

    # Exit with 0 if there is a first log, 1 if there is not
    [[ -n "$first_log" ]]
  }

  git_prompt_branch_exists () {
    # List remote branches           | # Find our branch and exit with 0 or 1 if found/not found
    git branch --remote 2> /dev/null | grep --quiet "$1"
  }

  git_prompt_parse_git_ahead () {
    # Grab the local and remote branch
    branch="$(git_prompt_get_git_branch)"
    remote="$(git config --get "branch.${branch}.remote" || echo -n "origin")"
    remote_branch="$remote/$branch"

    # $ git log origin/master..master
    # commit 4a633f715caf26f6e9495198f89bba20f3402a32
    # Author: Todd Wolfson <todd@twolfson.com>
    # Date:   Sun Jul 7 22:12:17 2013 -0700
    #
    #     Unsynced commit

    # If the remote branch is behind the local branch
    # or it has not been merged into origin (remote branch doesn't exist)
    if (git_prompt_is_branch1_behind_branch2 "$remote_branch" "$branch" ||
        ! git_prompt_branch_exists "$remote_branch"); then
      # echo our character
      echo 1
    fi
  }

  git_prompt_parse_git_behind () {
    # Grab the branch
    branch="$(git_prompt_get_git_branch)"
    remote="$(git config --get "branch.${branch}.remote" || echo -n "origin")"
    remote_branch="$remote/$branch"

    # $ git log master..origin/master
    # commit 4a633f715caf26f6e9495198f89bba20f3402a32
    # Author: Todd Wolfson <todd@twolfson.com>
    # Date:   Sun Jul 7 22:12:17 2013 -0700
    #
    #     Unsynced commit

    # If the local branch is behind the remote branch
    if git_prompt_is_branch1_behind_branch2 "$branch" "$remote_branch"; then
      # echo our character
      echo 1
    fi
  }

  function git_prompt_parse_git_dirty() {
    # If the git status has *any* changes (e.g. dirty), echo our character
    if [[ -n "$(git status --porcelain 2> /dev/null)" ]]; then
      echo 1
    fi
  }

  ######################################################################################################################

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

    git_status() {
      if [ -e "$PWD/.git" ]; then
        git_prompt_get_git_status
      fi
    }

    git_progress() {
      if [ -e "$PWD/.git" ]; then
        git_prompt_get_git_progress
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

        PS1="${PS1}\[\033[40m\]\[\033[32m\] \`git_status\`"
        PS1="${PS1} \`git_progress\`"
        PS1="${PS1}\[\033[40m\]\033[K" # force colour to end of line

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
