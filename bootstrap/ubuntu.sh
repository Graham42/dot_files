#!/usr/bin/env bash

# Goals of this script:
#  - Fully configure an ubuntu system.
#  - Nothing should be configured manually.
#  - Should be rerunnable to update system.

# Usage:
#     wget https://github.com/Graham42/dot_files/raw/master/bootstrap/ubuntu.sh
#     bash ./ubuntu.sh

set -e
set -o pipefail
set -x

################################################################################
# Packages
################################################################################

install_if_needed() {
    sudo apt-get install -y "$@"
}

remove_if_installed() {
    sudo apt-get remove -y "$@"
}

apt_source_exists() {
    for file in /etc/apt/sources.list.d/$1.list; do
        if [ -e "$file" ]; then
            echo "Source already exists: $file"
            return 0
        fi
    done
    return 1
}
# pre-reqs for this script
install_if_needed wget
# packages to allow apt to use a repository over HTTPS
install_if_needed \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Other PPAs

# Want the latest features available in git such as conditional includes
apt_source_exists git-core* || sudo add-apt-repository ppa:git-core/ppa
# Peek is an animated GIF recorder
apt_source_exists peek-* || sudo add-apt-repository ppa:peek-developers/stable
# Chrome
apt_source_exists google || ( \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list' \
)
# Visual Studio Code
apt_source_exists vscode || ( \
    wget https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable -O /tmp/vscode.deb && \
    sudo apt-get install -y /tmp/vscode.deb \
)
# Docker
apt_source_exists docker || ( \
    curl -fsSL -o /tmp/docker.pub https://download.docker.com/linux/ubuntu/gpg && \
    `# verify the fingerprint` \
    cat /tmp/docker.pub | \
        gpg --with-colons --import-options import-show --dry-run --import | \
        grep -q '^fpr.*0EBFCD88' && \
    sudo apt-key add /tmp/docker.pub && \
    sudo sh -c 'echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list' \
)
apt_source_exists spotify || (
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90 && \
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
)
apt_source_exists lubomir-brindza-ubuntu-nautilus-typeahead-bionic || (
    echo deb http://ppa.launchpad.net/lubomir-brindza/nautilus-typeahead/ubuntu bionic main | sudo tee /etc/apt/sources.list.d/lubomir-brindza-ubuntu-nautilus-typeahead-bionic.list
)
# Perfoce
#apt_source_exists perforce || ( \
#    curl -fsSL -o /tmp/perforce.pubkey https://package.perforce.com/perforce.pubkey && \
#    `# verify the fingerprint` \
#    cat /tmp/perforce.pubkey | \
#        gpg --with-colons --import-options import-show --dry-run --import | \
#        grep -q '^fpr:*E58131C0AEA7B082C6DC4C937123CB760FF18869' && \
#    sudo apt-key add /tmp/perforce.pubkey && \
#    sudo sh -c 'echo "deb http://package.perforce.com/apt/ubuntu $(lsb_release -cs) release" > /etc/apt/sources.list.d/perforce.list' \
#)

# load new ppas
sudo apt-get update

install_if_needed \
`# version control system` \
    git \
`# text editor, gtk version includes +clipboard support for copying to system clipboard` \
    vim-gtk \
`# text editor, AKA Visual Studio Code` \
    code \
`# drop down terminal` \
    guake \
`# terminal multiplexer, easy management of multiple terminal panes in single window` \
    tmux \
`# animated GIF recorder` \
    peek \
    google-chrome-stable \
`# utility for grabbing to clipboard` \
    xclip \
`# container runtime` \
    docker-ce \
`# shell script linting tool` \
    shellcheck \
`# make, gcc, etc` \
    build-essential \
    python \
`# simple image editor` \
    pinta \
`# music player` \
    spotify-client\
`# media player` \
    vlc \
`# needed for android / react native dev` \
    openjdk-8-jdk \
    adb \
    imagemagick \
`# tweak gnome settings` \
    gnome-tweak-tool \
    gnome-shell-extensions \
`# GUI for browsing dconf/gnome settings` \
    dconf-editor

remove_if_installed \
    gnome-shell-extension-ubuntu-dock

sudo apt-get upgrade -y
# Install nvm
LATEST_NVM_VERSION=$(curl --silent "https://api.github.com/repos/creationix/nvm/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
# Try an load nvm if it's already installed
# shellcheck source=/dev/null
source "$HOME/.nvm/nvm.sh" > /dev/null 2>&1 || true
CURRENT_NVM_V=$(nvm --version || echo NOPE)
if [ "$LATEST_NVM_VERSION" != "v$CURRENT_NVM_V" ]; then
    curl -f -o- "https://raw.githubusercontent.com/creationix/nvm/$LATEST_NVM_VERSION/install.sh" | bash

    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
fi
# this is super noisy with -x
set +x
echo installing nvm lts/*
nvm install lts/*
set -x
nvm alias default lts/*
npm install -g npm

################################################################################
# Config
################################################################################

#if [ -e ~/dot_files ]; then
#    (cd ~/dot_files && git pull)
#else
#    (cd && git clone https://github.com/Graham42/dot_files.git)
#fi
#
#(cd ~/dot_files && \
#    ./init_all.sh
#)
