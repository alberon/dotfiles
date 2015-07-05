export PAGER=less

# If output fits on one screen exit immediately
export LESS=FRSX

# Grep with pager
# Note: This has to be a script not a function so it can detect a pipe
# But the script cannot be called "grep", because that gets called by scripts
# So we have a function "grep" calling a script "grep-less"
if ! $WINDOWS; then
    alias grep="grep-less"
fi
