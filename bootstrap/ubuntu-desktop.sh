#!/usr/bin/env bash

# Goals of this script:
#  - Fully configure an ubuntu system.
#  - Nothing should be configured manually.
#  - Should be rerunnable to update system.

# Usage:
#     wget https://github.com/Graham42/dot_files/raw/master/bootstrap/ubuntu.sh
#     bash ./ubuntu-desktop.sh

set -e
set -o pipefail
set -x

./bootstrap/ubuntu.sh

################################################################################
# Packages
################################################################################

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
sudo apt-get install -y wget
# packages to allow apt to use a repository over HTTPS
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Other PPAs

# Peek is an easy-to-use screen recorder that can ouput animated GIFs
apt_source_exists peek-* || sudo add-apt-repository ppa:peek-developers/stable
# Chrome
apt_source_exists google-chrome || ( \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' \
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
    curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
)
apt_source_exists lubomir-brindza-ubuntu-nautilus-typeahead-bionic || (
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys F2171AE78ECBC8C6F059FD98301F60F1D6A30942 && \
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

sudo apt-get install -y \
`# text editor, AKA Visual Studio Code` \
    code \
`# animated GIF recorder` \
    peek \
    google-chrome-stable \
`# container runtime` \
    docker-ce \
`# image editor` \
    gimp \
`# music player` \
    spotify-client\
`# media player` \
    vlc \
`# tweak gnome settings` \
    gnome-tweak-tool \
    gnome-shell-extensions \
`# GUI for browsing dconf/gnome settings` \
    dconf-editor

sudo apt-get upgrade -y

LATEST_HYPER=$(curl -L --silent "https://api.github.com/repos/zeit/hyper/releases/latest" |
    grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if ! command -v hyper || [ "$(hyper version)" != "$LATEST_HYPER" ]; then
    TEMP_DIR=$(mktemp -d)
    curl -L -o "$TEMP_DIR/hyper.deb" https://releases.hyper.is/download/deb
    sudo apt-get install -y "$TEMP_DIR/hyper.deb"
fi

./bootstrap/ubuntu-desktop-18.04.sh
