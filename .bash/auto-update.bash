if $HAS_TERMINAL; then

    # Check what the current revision is
    old_head=$(cd; git rev-parse HEAD)

    # Catch Ctrl-C - sometimes if GitHub or my internet connection is down I
    # need to be able to cancel the update without skipping the rest of .bashrc
    trap 'echo' INT

    # Run the auto-update
    ~/bin/cfg-auto-update

    trap - INT

    # Reload Bash if any changes were made
    if [ "$(cd; git rev-parse HEAD)" != "$old_head" ]; then
        exec bash -l
    fi

fi
