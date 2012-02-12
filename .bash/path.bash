# Add my own bin directories to the path
export PATH="$HOME/local/bin:$HOME/bin:$HOME/opt/git-extras/bin:$HOME/opt/drush:$PATH"

# And man pages
if which manpath >/dev/null 2>&1; then
    export MANPATH="$HOME/opt/git-extras-man:$(manpath 2>/dev/null)"
fi
