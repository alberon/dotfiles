if $HAS_TERMINAL; then

    # Start typing then use Up/Down to see *matching* history items
    bind '"\e[A":history-search-backward'
    bind '"\e[B":history-search-forward'

    # Don't store duplicate entries in history
    export HISTIGNORE="&"

    # Save history immediately, so multiple terminals don't overwrite each other!
    shopt -s histappend
    PROMPT_COMMAND='history -a'

    # History with additional time information
    alias history-time='HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] " history'

fi
