#!/bin/bash

# Based on:
# https://raw.github.com/mislav/git-deploy/master/lib/hooks/post-receive.sh

# Use this separator to make it more noticable in the output on the remote site
# It is 72 chars wide because the prefix "remote: " is 8 chars wide
echo "========================================================================"

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

# Get the current branch
head="$(git symbolic-ref HEAD)"
# Abort if we're on a detached head
[ "$?" != "0" ] && exit 1

# Read the STDIN to detect if this push changed the current branch
while read oldrev newrev refname
do
    [ "$refname" = "$head" ] && break
done

# Abort if there's no update, or in case the branch is deleted
[ -z "${newrev//0}" ] && exit

# Check out the latest code into the working copy
echo "Updating working copy..."
umask 002
git reset --hard

echo "========================================================================"
