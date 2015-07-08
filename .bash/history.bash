if $HAS_TERMINAL; then

    # Start typing then use Up/Down to see *matching* history items
    bind '"\e[A":history-search-backward'
    bind '"\e[B":history-search-forward'

    # Don't store duplicate entries in history
    export HISTIGNORE="&"

    # Save history immediately, so multiple terminals don't overwrite each other!
    shopt -s histappend
    PROMPT_COMMAND='history -a'

    # Record multi-line commands as a single entry
    shopt -s cmdhist

    # Preserve new lines in history instead of converting to semi-colons
    shopt -s lithist

    # Confirm history expansions (e.g. "!1") before running them
    shopt -s histverify

    # If a history expansion fails, let the user re-edit the command
    shopt -s histreedit

    # Display history with additional time information
    alias history-time='HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] " history'

fi
