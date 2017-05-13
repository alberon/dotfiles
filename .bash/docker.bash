alias d='winpty docker'
alias dc='winpty docker-compose'
alias dm='winpty docker-machine'

dsh()
{
    # Determine the image ID, build it if necessary
    image="${1:-.}"

    if [ "$image" = "." ]; then
        image="$(docker build -q .)"

        if [ -z "$image" ]; then
            return
        fi
    fi

    # Set up SSH agent forwarding
    if [ -n "$SSH_AUTH_SOCK" ]; then
        opt="--volume \$SSH_AUTH_SOCK:/tmp/ssh-agent --env SSH_AUTH_SOCK=/tmp/ssh-agent"
    else
        opt=
    fi

    # Build the command to run Bash on the specified image
    local cmd="docker run $opt -it $image ${2:-bash}"

    # If using Windows, we need to connect to the Docker VM first
    if $WINDOWS; then
        # -A = Enable agent forwarding, -t = Force TTY allocation
        winpty docker-machine ssh $DOCKER_MACHINE_NAME -At "$cmd"
    else
        # Untested...
        $cmd
    fi
}

dme()
{
    echo "Switching Docker environment..."
    winpty eval $(docker-machine env "${1:-default}")
}

winpty()
{
    if $WINDOWS; then
        "$HOME/opt/winpty/bin/winpty.exe" "$@"
    else
        "$@"
    fi
}
