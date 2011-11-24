#!/bin/bash

# If the script has been called as a hook, chdir to the working copy
if [ "$GIT_DIR" = "." ]; then
    cd ..
    GIT_DIR=.git
    export GIT_DIR
fi

# Try to obtain the usual system PATH
if [ -f /etc/profile ]; then
    PATH=$(source /etc/profile; echo $PATH)
    export PATH
fi

# Check for local changes to working copy or stage, including untracked files
if [ -n "$(git status --porcelain)" ]; then
    echo >&2 "========================================================================"
    echo >&2 "Error: The remote has uncommitted changes."
    echo >&2 "========================================================================"
    exit 1
fi
