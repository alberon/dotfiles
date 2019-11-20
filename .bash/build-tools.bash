# Grunt
if command -v grunt &>/dev/null; then
    eval "$(grunt --completion=bash)"
fi

p() {
    red bold "The 'p' (gulp) command is deprecated - you should use 'a' (assets) instead, which supports webpack"
    gulp "$@"
}
