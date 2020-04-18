if $HAS_TERMINAL; then

    if command -v thefuck &>/dev/null; then
        eval $(thefuck --alias)
    fi

fi
