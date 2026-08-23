#!/usr/bin/env bash

# Installs a Nerd Font (https://www.nerdfonts.com/) system-wide.
#
# Usage: ./nerd-font.sh [FontName]
#   FontName defaults to UbuntuMono. Must match a release asset basename from
#   https://github.com/ryanoasis/nerd-fonts/releases (e.g. FiraCode, Hack,
#   JetBrainsMono), not the display name shown on nerdfonts.com.
#
# Default monospace font per distro, for reference (as of 2026):
#   - Ubuntu (GNOME/Yaru, 24.04+): "Ubuntu Mono" - part of the Ubuntu font
#     family Canonical refreshed for the 24.04/26.04 cycle. Check with
#     `gsettings get org.gnome.desktop.interface monospace-font-name`.
#   - Linux Mint (Cinnamon, Mint-Y theme): "DejaVu Sans Mono" 10 - despite
#     Mint being Ubuntu-based and shipping Ubuntu Mono/Ubuntu Sans Mono too,
#     Cinnamon hasn't switched its default (see linuxmint/cinnamon#13889).
#     Check via System Settings > Fonts (Cinnamon has no gsettings key for
#     this - the choice lives behind its own font-picker dialog).
#   Defaulting this script to UbuntuMono installs the Nerd Font patched
#   version of Ubuntu's own default, which is a reasonable pick on either
#   distro; pass a different name if you'd rather match Mint's DejaVu default
#   or use something else entirely.

set -euo pipefail

function log {
  echo -e "\033[34m$*\033[0m"
}

font="${1:-UbuntuMono}"

command -v unzip >/dev/null || sudo apt-get install -y unzip

log "Fetching latest Nerd Fonts release tag..."
tag=$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r .tag_name)

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

log "Downloading ${font} Nerd Font (${tag})..."
curl -fsSL -o "${tmpdir}/${font}.zip" \
  "https://github.com/ryanoasis/nerd-fonts/releases/download/${tag}/${font}.zip"

log "Extracting..."
unzip -q "${tmpdir}/${font}.zip" -d "${tmpdir}/${font}"

log "Installing to /usr/local/share/fonts..."
sudo mkdir -p /usr/local/share/fonts
sudo cp "${tmpdir}/${font}"/*.ttf /usr/local/share/fonts/

log "Refreshing font cache..."
sudo fc-cache -f >/dev/null

log "Done. Restart your terminal to see ${font} Nerd Font."
