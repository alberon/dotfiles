# This seems to be loaded automatically on some servers and not on others
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

source ~/.bash_completion

# Don't tab-complete an empty line - there's not really any use for it
shopt -s no_empty_cmd_completion
