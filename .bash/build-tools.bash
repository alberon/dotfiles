gulp()
{
    # Gulper automatically reloads gulp when the Gulpfile is modified
    if command -v gulper &>/dev/null; then
        gulper "$@"
    else
        command gulp "$@"
    fi
}

alias a='awe'
alias aweup='sudo npm update -g awe'
alias p='gulp'

# Use the development version of Awe in preference to the stable version
PATH="$HOME/awe/bin:$PATH"
