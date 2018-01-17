#!/usr/bin/env sh

# Goals of this script:
#  - Fully configure a ubuntu system.
#  - Nothing should be configured manually.
#  - Should be rerunnable to update system.

install_if_needed(){
    dpkg-query -W "$@" || sudo apt-get install -y "$@"
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

# other ppas ...
apt_source_exists git-core* || sudo add-apt-repository ppa:git-core/ppa
# Peek is an animated GIF recorder
apt_source_exists peek-* || sudo add-apt-repository ppa:peek-developers/stable
# chrome
apt_source_exists google-chrome || ( \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    )
# VSCode
apt_source_exists vscode || ( \
    wget https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable -O /tmp/vscode.deb && \
    sudo apt-get install /tmp/vscode.deb \
    )

# load new ppas
sudo apt-get update

install_if_needed \
    git \
    tmux \
    neovim \
    peek \
    google-chrome-stable \
    xclip \
    guake \
    code

sudo apt-get upgrade -y
