#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")/.."

################################################################################
# Run the setup script as a regular user.
################################################################################

# Rebuild the image if the 'cfg' script changes (if not it's cached so this is quick)
scripts/_build.sh

opt=()
if [[ -n $SSH_AUTH_SOCK ]]; then
    opt=(--volume $SSH_AUTH_SOCK:/tmp/ssh-agent --env SSH_AUTH_SOCK=/tmp/ssh-agent)
fi

# For debugging (to see errors without tmux exiting immediately):
#exec docker run "${opt[@]}" -it --rm dotfiles

exec docker run "${opt[@]}" -it --rm --entrypoint /usr/bin/tmux dotfiles -2 new -A -s test
