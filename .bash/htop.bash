# Older versions of htop don't like non-standard $TERM's like screen-256color,
# but I can't change that because it would cause nested tmux's when using ssh or
# su. Tested on 0.8.3 (CentOS) which needs it and 1.0.1 (Debian) which doesn't.
alias htop='TERM=xterm-256color htop'
