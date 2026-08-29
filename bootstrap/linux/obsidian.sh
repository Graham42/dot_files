#!/usr/bin/env bash

# Installs Obsidian (the note-taking app), from the .deb GitHub publishes.
#
# Obsidian has no apt repo, so this is a download-and-install rather than
# another entry in desktop-common.sh's package list - the same reason
# pia-vpn.sh is its own script. See that script for the general pattern this
# follows.
#
# One quirk specific to Obsidian: GitHub's "latest release" for
# obsidianmd/obsidian-releases sometimes points at a mobile-only build (just
# an .apk, no .deb) - the repo covers every platform, and not every tagged
# release ships a desktop build. So this walks recent releases instead of
# trusting /releases/latest, and takes the newest one that actually has an
# amd64 .deb.
#
# Only amd64 has a .deb; there's no arm64 build, so arm64 machines are
# skipped the way desktop-common.sh skips 1Password.

set -euo pipefail

API_URL="https://api.github.com/repos/obsidianmd/obsidian-releases/releases?per_page=10"

log() {
    echo -e "\033[34m$*\033[0m"
}

warn() {
    echo -e "\033[33m$*\033[0m" >&2
}

if [ "$(dpkg --print-architecture)" != "amd64" ]; then
    warn "Skipping Obsidian: no .deb build for $(dpkg --print-architecture), only amd64."
    exit 0
fi

log "Looking up the latest Obsidian .deb release..."
# Walk releases newest-first and take the first with an amd64 .deb asset,
# rather than assuming /releases/latest has one (see header).
url=$(curl -fsSL "$API_URL" \
    | grep -oE 'https://github\.com/obsidianmd/obsidian-releases/releases/download/[^"]*_amd64\.deb' \
    | head -1)
if [ -z "$url" ]; then
    echo "Could not find an amd64 .deb in the last 10 releases at $API_URL" >&2
    exit 1
fi

deb="${url##*/}"
# obsidian_1.13.7_amd64.deb -> 1.13.7
version="${deb#obsidian_}"
version="${version%_amd64.deb}"

installed=$(dpkg-query -W -f='${Version}' obsidian 2>/dev/null || true)
if [ "$installed" = "$version" ]; then
    log "Obsidian $version is already installed."
    exit 0
elif [ -n "$installed" ]; then
    log "Upgrading Obsidian $installed to $version..."
else
    log "Installing Obsidian $version..."
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

log "Downloading $deb..."
curl -fSL --progress-bar -o "$tmpdir/$deb" "$url"

# apt rather than dpkg so any missing dependencies get pulled in.
sudo apt-get install -y "$tmpdir/$deb"
