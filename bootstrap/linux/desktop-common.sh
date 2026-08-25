#!/usr/bin/env bash

# Shared desktop setup for the Ubuntu/apt family (Ubuntu, Linux Mint, ...).
# Sourced by ubuntu-desktop.sh and mint-desktop.sh - everything here is
# desktop-environment agnostic. Anything tied to a specific DE stays in the
# per-distro script instead: the GNOME bits (gnome-tweaks,
# gnome-shell-extensions) are Ubuntu-only, since Mint ships Cinnamon.
#
# Typical use from a per-distro script:
#
#   source "$script_dir/desktop-common.sh"
#   desktop_common_prereqs
#   ...add distro-specific apt repos here...
#   desktop_common_repos
#   desktop_common_install <extra packages...>

desktop_common_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./apt-repo-common.sh
source "$desktop_common_dir/apt-repo-common.sh"

# Desktop software wanted on every machine. Per-distro scripts pass their own
# extras to desktop_common_install.
DESKTOP_COMMON_PACKAGES=(
    # browser
    google-chrome-stable
    # text editor, AKA Visual Studio Code
    code
    # image editor
    gimp
    # music player
    spotify-client
    # media player
    vlc
    # GUI for browsing dconf settings (used by both GNOME and Cinnamon)
    dconf-editor
)

# Tools this script itself needs to add the repos below.
desktop_common_prereqs() {
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        software-properties-common
}

# Third-party apt repos needed by DESKTOP_COMMON_PACKAGES. Call after any
# distro-specific repos; desktop_common_install runs the `apt-get update`
# that picks all of them up.
desktop_common_repos() {
    # Chrome
    apt_source_exists google-chrome || add_apt_key_repo \
        https://dl.google.com/linux/linux_signing_key.pub \
        /etc/apt/keyrings/google-chrome.gpg \
        google-chrome \
        "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main"

    # Visual Studio Code
    apt_source_exists vscode || add_apt_key_repo \
        https://packages.microsoft.com/keys/microsoft.asc \
        /etc/apt/keyrings/microsoft.gpg \
        vscode \
        "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main"

    # Spotify
    apt_source_exists spotify || add_apt_key_repo \
        https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc \
        /etc/apt/keyrings/spotify.gpg \
        spotify \
        "deb [signed-by=/etc/apt/keyrings/spotify.gpg] https://repository.spotify.com stable non-free"

    # TODO: screen recorder / animated GIF tool. Peek (previously installed
    # via ppa:peek-developers/stable) is dead upstream - archived by its
    # maintainer in Sept 2025 - and its PPA never built past Ubuntu 22.04, so
    # it just fails to install now. Find a replacement (e.g. Kooha via
    # flatpak, or a screencast mode built into the DE's screenshot tool).

    # TODO: container runtime. Previously installed docker-ce here (apt-key
    # based, and missing the compose/buildx plugins). Decide on a replacement
    # approach and add it back with modern signed-by key handling.
}

# Usage: desktop_common_install [extra packages...]
# Loads the newly added sources, installs the common packages plus whatever
# the per-distro script passes in, then upgrades the system.
desktop_common_install() {
    sudo apt-get update
    sudo apt-get install -y "${DESKTOP_COMMON_PACKAGES[@]}" "$@"
    sudo apt-get upgrade -y
}
