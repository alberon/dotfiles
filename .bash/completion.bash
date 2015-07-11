# This seems to be loaded automatically on some servers and not on others
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# Don't tab-complete an empty line - there's not really any use for it
shopt -s no_empty_cmd_completion

# Custom completions
# complete -C "z --bash-completion" z

complete -F _z_completion z

_z_completion() {
    # Locate the scripts directory
    if ! root="$(findup -d scripts)"; then
        return
    fi

    scripts="$root/scripts"

    # Subdirectory?
    for ((i = 1; i < $COMP_CWORD; i++)); do
        scripts="$scripts/${COMP_WORDS[$i]}"
    done

    if [ ! -d "$scripts" ]; then
        return
    fi

    # List matching scripts
    COMPREPLY=()

    for file in "$scripts/${COMP_WORDS[$COMP_CWORD]}"*; do
        name="$(basename "$file")" # Remove path
        name="${name%%.*}"         # Remove extension
        if [ ! -x "$file" ]; then
            : # Skip non-executable files
        elif [ "${name^^}" = "README" ]; then
            : # Skip readme files
        elif [[ "$name" == *" "* ]]; then
            # Spaces in the name
            COMPREPLY+=("'$name'")
        else
            COMPREPLY+=("$name")
        fi
    done
}
