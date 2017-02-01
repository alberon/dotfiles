export PAGER=less

# If output fits on one screen exit immediately
export LESS=FRX

# Grep with pager
# Note: This has to be a script not a function so it can detect a pipe
# But the script cannot be called "grep", because that gets called by scripts
# So we have a function "grep" calling a script "grep-less"
# And we need to use 'which' so that 'sudo grep' works
if ! $WINDOWS; then
    alias grep="$(which grep-less)"
fi
