alias sshstop='ssh -O stop'

# Fix running chromium via SSH
if [ -z "$XAUTHORITY" ]; then
    export XAUTHORITY=$HOME/.Xauthority
fi
