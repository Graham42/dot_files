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
#   desktop_common_remap_keys

desktop_common_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./apt-repo-common.sh
source "$desktop_common_dir/apt-repo-common.sh"

# Desktop software wanted on every machine. Per-distro scripts pass their own
# extras to desktop_common_install. add_1password_repo adds to this list too,
# but only on amd64.
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

# 1Password. Steps follow https://support.1password.com/install-linux/
#
# This takes more setup than the repos below. On top of the apt repo
# signature, dpkg checks the signature inside the .deb itself. That check
# needs a debsig policy and key, or the install fails.
#
# The desktop app is amd64 only, so this skips other machines. The arm64
# repo has 1password-cli but no desktop app; install that one by hand:
#   curl -sSO https://downloads.1password.com/linux/tar/stable/aarch64/1password-latest.tar.gz
#   sudo tar -xf 1password-latest.tar.gz
#   sudo mkdir -p /opt/1Password && sudo mv 1password-*/* /opt/1Password
#   sudo /opt/1Password/after-install.sh
#
# Two things still have to be set up by hand after this runs: the global
# shortcut (https://support.1password.com/keyboard-shortcuts/?linux - note
# Ubuntu LTS runs Wayland), and, on GNOME, the AppIndicator extension for
# the tray icon.
add_1password_repo() {
    local key_url=https://downloads.1password.com/linux/keys/1password.asc
    # 1Password documents /usr/share/keyrings, not the /etc/apt/keyrings the
    # repos below use. Keep their path so a machine set up from their
    # instructions doesn't end up with two copies of the key.
    local keyring=/usr/share/keyrings/1password-archive-keyring.gpg
    # Last 16 hex of their signing key fingerprint
    # (3FEF9748469ADBE15DA7CA80AC2D62742012EA22). debsig finds the policy and
    # the key by this id, so it can't be renamed.
    local debsig_id=AC2D62742012EA22

    if [ "$(dpkg --print-architecture)" != "amd64" ]; then
        echo "Skipping 1Password: desktop app is amd64 only"
        return 0
    fi

    # Added here rather than to the list itself, so the package and the repo
    # setup stay in sync.
    DESKTOP_COMMON_PACKAGES+=(1password)

    apt_source_exists 1password || add_apt_key_repo \
        "$key_url" \
        "$keyring" \
        1password \
        "deb [arch=amd64 signed-by=$keyring] https://downloads.1password.com/linux/debian/amd64 stable main"

    # Runs even when the repo was already added: machines set up before this
    # existed have the repo but no policy. Repeating it is harmless.
    sudo install -m 0755 -d "/etc/debsig/policies/$debsig_id"
    curl -fsSL https://downloads.1password.com/linux/debian/debsig/1password.pol \
        | sudo tee "/etc/debsig/policies/$debsig_id/1password.pol" >/dev/null
    sudo install -m 0755 -d "/usr/share/debsig/keyrings/$debsig_id"
    # The name must be debsig.gpg. 1password.pol asks for it by name.
    curl -fsSL "$key_url" \
        | sudo gpg --dearmor --yes -o "/usr/share/debsig/keyrings/$debsig_id/debsig.gpg"
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

    # 1Password - needs debsig and an arch check, see the function above
    add_1password_repo

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

# Remaps Caps Lock to F14. On Ubuntu that is the key the drop-down terminal
# opens with; on Mint nothing is bound to it yet. Safe to run again, and it
# leaves a hand-written /etc/keyd/default.conf alone. See remap-keys.sh.
desktop_common_remap_keys() {
    "$desktop_common_dir/remap-keys.sh"
}
