#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")/.."

################################################################################
# Run the setup script as the root user.
################################################################################

# Rebuild the image if the 'cfg' script changes (if not it's cached so this is quick)
scripts/_build.sh

source ~/.bash/000-vars.bash
source ~/.bash/docker.bash

# Use SSH with agent forwarding so we can commit changes made inside Docker
dsh dotfiles /bin/bash -u root
