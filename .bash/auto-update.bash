# Check what the current revision is
old_head=$(git rev-parse HEAD)

# Run the auto-update
~/bin/cfg-auto-update

# Reload Bash if any changes were made
if [ "$(git rev-parse HEAD)" != "$old_head" ]; then
    exec bash -l
fi
