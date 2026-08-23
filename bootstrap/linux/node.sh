#!/usr/bin/env bash

# Installs Node.js (via fnm) and bun. Safe to re-run.
#
# Assumes a Rust toolchain is already installed (see ubuntu.sh).
#
# Usage: ./bootstrap/linux/node.sh

set -euo pipefail

function log {
  echo -e "\033[34m$*\033[0m"
}

################################################################################
## Node.js, via fnm (https://github.com/Schniz/fnm) - installs the current
## LTS release and sets it as fnm's default

if ! command -v cargo &>/dev/null; then
  echo "cargo not found - run ubuntu.sh (or install Rust via https://rustup.rs) first" >&2
  exit 1
fi

log "Installing fnm..."
cargo install --locked fnm
log "fnm installed"

eval "$(fnm env)"

log "Installing latest Node.js LTS..."
fnm install --lts
fnm default lts-latest
log "Node $(fnm current) set as fnm default"

################################################################################
## bun (https://bun.sh) - a separate all-in-one JS runtime/bundler/package
## manager, NOT bundled with Node.js/fnm

command -v unzip >/dev/null || sudo apt-get install -y unzip

if [ -x "$HOME/.bun/bin/bun" ]; then
  log "bun already installed ($("$HOME/.bun/bin/bun" --version)), skipping install"
else
  log "Installing bun..."
  # Official installer. It adds its own PATH line to ~/.bashrc/~/.zshrc
  # itself (same pattern as rustup/starship in ubuntu.sh) - unlike fnm, bun
  # has no extra shell hook (no .nvmrc-style auto-switching) so there's
  # nothing to add to home/.bashrc_extend.sh for it.
  curl -fsSL https://bun.sh/install | bash
  log "bun installed"
fi

log "Done. Restart your terminal (or 'source ~/.bashrc') to get fnm/node/bun on PATH."
