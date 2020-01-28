yarn() {
    if [ "$1" = "update" ]; then
        # yarn run v1.19.1
        # error Command "update" not found.
        # info Visit https://yarnpkg.com/en/docs/cli/run for documentation about this command.
        shift
        command yarn upgrade "$@"
    else
        command yarn "$@"
    fi
}
