#!/bin/bash

# Based on:
# https://raw.github.com/mislav/git-deploy/master/lib/hooks/post-receive.sh
#
# To test it:
# git push-hook -f && echo "X X $(git symbolic-ref HEAD)" | .git/hooks/post-receive

# Use this separator to make it more noticable in the output on the remote site
# It is 72 chars wide because the prefix "remote: " is 8 chars wide
draw_line() {
    echo "========================================================================"
}

draw_line

# If the script has been called as a hook, chdir to the working copy
if [ "$GIT_DIR" = "." ]; then
    cd ..
    export GIT_DIR=".git"
fi

# Try to obtain the usual system PATH
if [ -f /etc/profile ]; then
    export PATH="$(source /etc/profile; echo $PATH)"
fi

# Get the current branch
head="$(git symbolic-ref HEAD)"

# Abort if we're on a detached head
if [ "$?" != "0" ]; then
    echo "Remote is in 'detached HEAD' state, skipping push hook."
    draw_line
    exit
fi

# Read the STDIN to detect if this push changed the current branch
while read oldrev newrev refname; do
    [ "$refname" = "$head" ] && break
done

# Abort if there's no update, or in case the branch is deleted
if [ -z "${newrev//0}" ]; then
    echo "No updates to checked out '$(git symbolic-ref --short HEAD)' branch, skipping push hook."
    draw_line
    exit
fi

# Check out the latest code into the working copy
echo "Updating working copy..."
umask 022
git reset --hard

# Helper method
run_php()
{
    phpcli=$(command -v php-cli 2>/dev/null)

    if [ -n "$phpcli" ]; then
        # On CentOS 5 the CGI version is the default not CLI
        php-cli "$@"
    else
        php "$@"
    fi
}

# Update submodules
if [ -f .gitmodules ]; then
    echo
    echo "Updating submodules..."
    git submodule init &&
    git submodule sync &&
    git submodule update
fi

# Update Composer packages
if [ -f composer.json ]; then
    composer=$(command -v composer 2>/dev/null)
    if [ -n "$composer" ]; then
        echo
        echo "Installing Composer packages..."
        run_php $composer install --no-dev
    fi
fi

# Run Laravel migrations
if [ -f artisan ]; then
    echo
    echo "Migrating database..."
    run_php artisan migrate --force
fi

draw_line
