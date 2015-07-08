# Note: The most general ones should be at the top, and the most specific at the
# bottom (e.g. local script) so they override the general ones if needed

# MacPorts
$MAC && PATH="/opt/local/bin:/opt/local/sbin:$PATH"

# RVM
PATH="$HOME/.rvm/bin:$PATH"

# Composer packages (Boris, Drush, etc.)
PATH="$HOME/.composer/vendor/bin:$PATH"

# Manually installed packages
for bin in $HOME/opt/*/bin; do
    PATH="$bin:$PATH"
done

# Custom scripts
PATH="$HOME/bin:$PATH"

# Custom OS-specific scripts
if $MAC; then
    PATH="$HOME/bin/osx:$PATH"
elif $WINDOWS; then
    PATH="$HOME/bin/win:$PATH"
fi

# Custom local scripts (specific to a machine so not in Git)
PATH="$HOME/local/bin:$PATH"

# Export the path so subprocesses can use it
export PATH

# Add extra man pages
if which manpath >/dev/null 2>&1; then
    MANPATH="$(manpath 2>/dev/null)"
    MANPATH="$HOME/opt/git-extras-man:$MANPATH"
    export MANPATH
fi
