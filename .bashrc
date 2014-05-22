# Detect operating system
WINDOWS=false
MAC=false

case "`uname`" in
    MINGW32*) WINDOWS=true  ;;
    Darwin)   MAC=true ;;
esac

# Detect whether there's a terminal (rather than a command like scp),
# and check we're not running a forced command like in gitolite
if [ "$TERM" != "dumb" -a -z "$BASH_EXECUTION_STRING" ]; then
    HAS_TERMINAL=true
else
    HAS_TERMINAL=false
fi

# Immediately switch to tmux if possible
if $HAS_TERMINAL && [[ ! $TERM =~ screen ]] && which tmux >/dev/null 2>&1; then
    if tmux has-session 2>/dev/null; then
        exec tmux attach
    else
        exec tmux new -s $(hostname -s)
    fi
fi

# Standard config files, nicely split up
for file in ~/.bash/*; do
    source "$file"
done

# Custom settings for this machine/account
if [ -f ~/.bashrc_local ]; then
    source ~/.bashrc_local
fi

# *After* doing the rest, show the current directory contents, except in
# Git Bash home directory - there's a load of system files in there
if $HAS_TERMINAL && ! ($WINDOWS && [ "$PWD" = "$HOME" ]); then
    c .
fi

# Git Bash loads this file *and* .bash_profile so set a flag to tell
# .bash_profile not to load .bashrc again
BASHRC_DONE=true
