#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")/.."

################################################################################
# Build Docker image.
################################################################################

source ~/.bash/000-vars.bash
source ~/.bash/docker.bash
docker build -t dotfiles .
