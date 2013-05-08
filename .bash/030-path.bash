# Note: The most general ones should be at the top, and the most specific at the
# bottom (e.g. local script) so they override the general ones if needed

# MacPorts
$MAC && PATH="/opt/local/bin:/opt/local/sbin:$PATH"

# RVM
PATH="$HOME/.rvm/bin:$PATH"

# WP-CLI - note: should go before ~/opt/boris/bin to use my version not theirs
PATH="$HOME/.composer/bin:$PATH"

# My packages
for bin in $HOME/opt/*/bin; do
    PATH="$bin:$PATH"
done

PATH="$HOME/opt/drush:$PATH"

# My scripts
PATH="$HOME/bin:$PATH"

# My Mac-specific scripts
$MAC && PATH="$HOME/bin/osx:$PATH"

# My local scripts
PATH="$HOME/local/bin:$PATH"

# Export the path so subprocesses can use it
export PATH

# Add extra man pages
if which manpath >/dev/null 2>&1; then
    MANPATH="$(manpath 2>/dev/null)"
    MANPATH="$HOME/opt/git-extras-man:$MANPATH"
    export MANPATH
fi
