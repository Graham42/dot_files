#!/usr/bin/env bash
# This script is for use either on ubuntu desktop or in WSL
set -e -o pipefail
set -x

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

# I want the latest features available in git, not just what's available from
# the Ubuntu LTS repository
apt_source_exists git-core* || sudo add-apt-repository ppa:git-core/ppa

# load new ppas
sudo apt-get update

sudo apt-get install -y \
`# version control system` \
    git \
`# text editor, gtk version includes +clipboard support for copying to system clipboard` \
    vim-gtk \
`# terminal multiplexer, easy management of multiple terminal panes in single window` \
    tmux \
`# utility for grabbing to clipboard` \
    xclip \
`# shell script linting tool` \
    shellcheck \
`# make, gcc, etc` \
    build-essential \
`# for python dev` \
    python3 \
    python3-pip \
`# tool for visualizing folder structures` \
    tree \
`# json manipulation tool` \
    jq \
`# Quickly find files anywhere on the system` \
    mlocate

pip install virtualenvwrapper

sudo apt-get upgrade -y

./bootstrap/nvm.sh

# bash prompt
curl -sS https://starship.rs/install.sh | sh
