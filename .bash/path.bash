# Add my own bin directories to the path
PATH="$HOME/opt/drush:$PATH"

for bin in $HOME/opt/*/bin; do
    PATH="$bin:$PATH"
done

PATH="$HOME/local/bin:$PATH:$HOME/bin"

export PATH

# And man pages
if which manpath >/dev/null 2>&1; then
    export MANPATH="$HOME/opt/git-extras-man:$(manpath 2>/dev/null)"
fi
