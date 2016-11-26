a()
{
    if findup -f awe.yaml; then
        # If awe.yaml exists in the project, use Awe
        awe "$@"
    else
        # Otherwise assume it's Gulp (the Gulpfile may have several names, e.g.
        # Gulpfile.js, gulpfile.babel.js, etc.
        gulp "$@"
    fi
}

gulp()
{
    # Gulper automatically reloads gulp when the Gulpfile is modified
    if which gulper >/dev/null 2>&1; then
        gulper "$@"
    else
        command gulp "$@"
    fi
}

alias aweup='sudo npm update -g awe'

# Use the development version of Awe in preference to the stable version
PATH="$HOME/awe/bin:$PATH"
