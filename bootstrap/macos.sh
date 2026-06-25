#!/usr/bin/env bash

set -e -u -o pipefail

function log {
  echo -e "\033[34m$*\033[0m"
}

# Homebrew is required — install it if missing
if ! command -v brew &>/dev/null; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  log "Homebrew installed"
fi

log "Updating Homebrew..."
brew update
log "Homebrew updated"

log "Installing packages..."
packages=(
  git
  vim
  jq
  tmux
  tree
  curl
  ripgrep   # rg
  fd        # fd (no alias needed on macOS, unlike fdfind on Ubuntu)
  shellcheck
)

brew install "${packages[@]}"
log "Packages installed"

log "Installing starship prompt..."
curl -sS https://starship.rs/install.sh | sh
log "Starship prompt installed"

# cargo / rust tools
if ! command -v cargo &>/dev/null; then
  log "Installing Rust toolchain..."
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  log "Rust installed"
fi
source "$HOME/.cargo/env"

log "Installing rust-based CLI tools..."
cargo install sd         # sed replacement
cargo install hyperfine  # benchmarking tool
cargo install zoxide     # smarter cd
log "Rust tools installed"
