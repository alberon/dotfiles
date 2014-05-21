# Workaround for losing SSH agent connection when reconnecting tmux:
# update a symlink to the socket each time we reconnect and use that
# as the socket in every session.
# (Also see ~/.ssh/rc)

if [ -S ~/.ssh/ssh_auth_sock ]; then
    export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
fi
