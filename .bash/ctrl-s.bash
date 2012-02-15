# Disable Ctrl-S = Stop output (except it's not available in Git's Cygwin)
if $HAS_TERMINAL && which stty >/dev/null; then
    stty -ixon
fi
