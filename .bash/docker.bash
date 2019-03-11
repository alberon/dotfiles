# Shorthand
alias d='docker'
alias db='docker build'
alias dc='docker-compose'
alias dr='docker run'
alias dri='docker run -it'

# Clean up stopped containers and dangling (untagged) images
dclean()
{
    docker container prune
    docker image prune
}

# Kill most recent container
dkill()
{
    container="${1:-}"
    if [ -z "$container" ]; then
        container="$(docker ps -qlf status=running)"
    fi

    if [ -n "$container" ]; then
        docker kill $container
    fi
}

# Kill all containers
dkillall()
{
    containers="$(docker ps -qf status=running)"

    if [ -n "$containers" ]; then
        docker kill $containers
    fi
}

# Resume
dresume()
{
    # http://stackoverflow.com/a/37886136/167815
    container="$(docker ps -qlf status=exited)"

    if [ -n "$container" ]; then
        docker start -ai "$container"
    else
        echo "No stopped images found." >&2
        return 1
    fi
}

# Serve a directory of files over HTTP for quick local sharing
# https://github.com/halverneus/static-file-server
dserve()
{
    dr -v "$PWD:/web" -p 80:8080 halverneus/static-file-server
}

# Shell
dsh()
{
    # Set up SSH agent forwarding
    if [ -n "$SSH_AUTH_SOCK" ]; then
        opt=(--volume $SSH_AUTH_SOCK:/tmp/ssh-agent --env SSH_AUTH_SOCK=/tmp/ssh-agent)
    else
        opt=()
    fi

    # Build the command to run a shell on the specified image
    local image="${1:-ubuntu}"
    local entrypoint="${2:-/bin/bash}"
    shift $(($# > 2 ? 2 : $#))

    docker run "${opt[@]}" -it "$@" --entrypoint "$entrypoint" "$image"
}

# Stop most recent container
dstop()
{
    container="${1:-}"
    if [ -z "$container" ]; then
        container="$(docker ps -qlf status=running)"
    fi

    if [ -n "$container" ]; then
        docker stop $container
    fi
}

# Stop all containers
dstopall()
{
    containers="$(docker ps -qf status=running)"

    if [ -n "$containers" ]; then
        docker stop $containers
    fi
}
