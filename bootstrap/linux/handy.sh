#!/usr/bin/env bash

# Installs Handy (https://handy.computer/), an open-source speech-to-text
# app, from the .deb GitHub publishes.
#
# Handy has no apt repo, so this is a download-and-install rather than
# another entry in desktop-common.sh's package list - the same pattern
# obsidian.sh follows (see that script for the general shape this copies).
#
# Unlike Obsidian, Handy ships a .deb for both amd64 and arm64, and its
# asset names use dpkg's own arch names (amd64/arm64) directly, so there's
# no arch skip or renaming needed here - just substitute in whichever arch
# dpkg reports.

set -euo pipefail

API_URL="https://api.github.com/repos/cjpais/Handy/releases?per_page=10"

log() {
    echo -e "\033[34m$*\033[0m"
}

arch="$(dpkg --print-architecture)"

log "Looking up the latest Handy .deb release for $arch..."
# Walk releases newest-first and take the first with a matching-arch .deb
# asset, rather than assuming /releases/latest has one (see obsidian.sh for
# why that assumption doesn't always hold).
url=$(curl -fsSL "$API_URL" \
    | grep -oE "https://github\.com/cjpais/Handy/releases/download/[^\"]*_${arch}\.deb" \
    | head -1)
if [ -z "$url" ]; then
    echo "Could not find a $arch .deb in the last 10 releases at $API_URL" >&2
    exit 1
fi

deb="${url##*/}"
# Handy_0.9.6_amd64.deb -> 0.9.6
version="${deb#Handy_}"
version="${version%_"$arch".deb}"

installed=$(dpkg-query -W -f='${Version}' handy 2>/dev/null || true)
if [ "$installed" = "$version" ]; then
    log "Handy $version is already installed."
else
    if [ -n "$installed" ]; then
        log "Upgrading Handy $installed to $version..."
    else
        log "Installing Handy $version..."
    fi

    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    # mktemp -d makes this 700, readable only by us. apt-get install on a
    # local path drops privileges to the _apt user to read/verify it before
    # install, and _apt can't see into a dir it has no access to - so open
    # it up.
    chmod 755 "$tmpdir"

    log "Downloading $deb..."
    curl -fSL --progress-bar -o "$tmpdir/$deb" "$url"

    # apt rather than dpkg so any missing dependencies get pulled in.
    sudo apt-get install -y "$tmpdir/$deb"
fi

# Autostart on login. Unlike PIA (see pia-vpn.sh), Handy has no in-app
# "launch on startup" setting to own this file - its README instead
# documents `--start-hidden --no-tray` for autostart scenarios. We keep the
# tray icon (drop --no-tray) so a running Handy stays visible/reachable
# after login instead of vanishing entirely.
#
# Written unconditionally (not just on fresh install) so re-running this
# script also turns autostart on for a machine that already had Handy.
log "Enabling Handy autostart on login..."
mkdir -p ~/.config/autostart
cat >~/.config/autostart/handy.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Handy
Comment=Speech-to-text (autostarted minimized to tray)
Exec=handy --start-hidden
Icon=handy
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
