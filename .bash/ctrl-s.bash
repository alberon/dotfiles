# Disable Ctrl-S = Stop output (except it's not available in Git's Cygwin)
if which stty >/dev/null; then
    stty -ixon
fi
