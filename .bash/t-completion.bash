_t_completion() {
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

complete -F _t_completion t
