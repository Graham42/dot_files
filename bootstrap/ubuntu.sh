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
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    `# verify the fingerprint` \
    apt-key adv --list-public-keys --with-fingerprint --with-colons Docker | cut -d ':' -f 5 | grep -q '0EBFCD88$' && \
    sudo sh -c 'echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list' \
)
 

# load new ppas
sudo apt-get update

install_if_needed \
`# version control system` \
    git \
`# text editor, gtk version includes +clipboard support for copying to system clipboard` \
    vim-gtk \
`# text editor, AKA Visual Studio Code` \
    code \
`# terminal multiplexer, easy management of multiple terminal panes in single window` \
    tmux \
`# drop down terminal, easy access to terminal with global system hotkey` \
    tilda \
`# animated GIF recorder` \
    peek \
    google-chrome-stable \
`# utility for grabbing to clipboard` \
    xclip \
`# container runtime` \
    docker-ce \
`# shell script linting tool` \
    shellcheck \
`# GUI for browsing dconf/gnome settings` \
    dconf-editor

remove_if_installed \
    gnome-shell-extension-ubuntu-dock

sudo apt-get upgrade -y


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
