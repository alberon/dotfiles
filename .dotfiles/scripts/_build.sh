#!/bin/bash
set -o nounset -o pipefail -o errexit
cd "$(dirname "$0")/.."

################################################################################
# Build Docker image.
################################################################################

exec docker build -t dotfiles .
