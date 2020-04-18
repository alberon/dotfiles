# This is needed to prevent this error when using SSH:
#   /usr/share/bash-completion/completions/ssh: line 357: syntax error near unexpected token `('
#   /usr/share/bash-completion/completions/ssh: line 357: `        !(*:*)/*|[.~]*) ;; # looks like a path'
# https://trac.macports.org/ticket/44558#comment:13
shopt -s extglob

# This seems to be loaded automatically on some servers and not on others

if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

source ~/.bash_completion

# Don't tab-complete an empty line - there's not really any use for it
shopt -s no_empty_cmd_completion
