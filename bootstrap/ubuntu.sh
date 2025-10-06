#!/usr/bin/env bash

set -e -u -o pipefail

function log {
  echo -e "\033[34m$*\033[0m"
}

log "Initial update and upgrade of system..."
sudo apt update && sudo apt upgrade -y
sudo apt autoremove
log "System updated"

log "Installing packages..."
packages=(
  # version control system
  git
  # text editor, gtk version includes +clipboard support for copying to system clipboard
  vim-gtk3
  # json manipulation tool
  jq
  # terminal multiplexer, easy management of multiple terminal panes in single window
  tmux
  # tool for visualizing folder structures
  tree
  # utility for grabbing to clipboard
  xclip
  # tool for downloading files
  curl
  # tool for searching code
  ripgrep
  # shell script linting tool
  shellcheck
)

sudo apt-get install -y "${packages[@]}"
log "Packages installed"

# bash prompt
log "Installing starship prompt..."
curl -sS https://starship.rs/install.sh | sh
log "Starship prompt installed"
