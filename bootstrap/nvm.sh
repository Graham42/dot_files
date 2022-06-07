#!/usr/bin/env bash
set -e -o pipefail
set -x

# Install nvm
LATEST_NVM_VERSION=$(curl -L --silent "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
# this is super noisy with -x
set +x
# Try an load nvm if it's already installed
# shellcheck source=/dev/null
source "$HOME/.nvm/nvm.sh" > /dev/null 2>&1 || true
CURRENT_NVM_V=$(nvm --version || echo NOPE)
if [ "$LATEST_NVM_VERSION" != "v$CURRENT_NVM_V" ]; then
    curl -L -f -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$LATEST_NVM_VERSION/install.sh" | bash

    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
fi
echo installing nvm lts/*
nvm install lts/*
nvm alias default lts/*
