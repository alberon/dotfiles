# Google Cloud Shell (required)
if $HAS_TERMINAL; then
    if [ -f "/google/devshell/bashrc.google" ]; then
        source "/google/devshell/bashrc.google"
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

# Prevent Serverless Framework messing with the Bash config
# https://github.com/serverless/serverless/issues/4069
# tabtab source for serverless package
# tabtab source for sls package
