# Disable Ctrl-S = Stop output (except it's not available in Git's Cygwin)
if $HAS_TERMINAL && which stty >/dev/null 2>&1; then
    stty -ixon
fi

# Use 4 space tabs
if $HAS_TERMINAL && which tabs >/dev/null 2>&1 && [ "$TERM" != "cygwin" ]; then
    # This outputs a blank line, but that doesn't seem preventable - if you
    # redirect to /dev/null it has no effect
    tabs -4
fi
