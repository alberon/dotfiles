gulp()
{
    # Gulper automatically reloads gulp when the Gulpfile is modified
    if which gulper >/dev/null 2>&1; then
        gulper "$@"
    else
        command gulp "$@"
    fi
}
