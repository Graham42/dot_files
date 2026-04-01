#!/usr/bin/env bash

if ! command -v nvim &>/dev/null; then
    echo "Neovim is not installed. Install it from your package manager (e.g. 'brew install neovim') or see: https://neovim.io/doc/install/"
    exit 1
fi

if [ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua" ]; then
    echo "Neovim config not found at ~/.config/nvim/init.lua — run the dotfiles symlink setup first."
    exit 1
fi

NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
mkdir -p "$NVIM_DATA/swap"
mkdir -p "$NVIM_DATA/undo"

# lazy.nvim is installed via git clone per its official install instructions:
# https://lazy.folke.io/installation
LAZY_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_PATH" ]; then
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_PATH"
fi

nvim --headless -c "Lazy sync" -c "qa"
