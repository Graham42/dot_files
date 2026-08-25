#!/usr/bin/env bash

# Shared helpers for adding third-party apt repositories the modern way.
# `apt-key` is deprecated since Debian 9 / Ubuntu 22.04 and fully removed as
# of Ubuntu 24.04, so a repo's key now lives in its own keyring file under
# /etc/apt/keyrings, referenced by `signed-by=` in that repo's
# sources.list.d entry, instead of everything sharing one global keyring.
#
# Sourced by both ubuntu-desktop.sh and mint-desktop.sh - keep this working
# on both (see get_apt_codename for the one place they actually differ).

# Ubuntu codename to use in repo URLs that need one, e.g.
#   ".../ubuntu $(get_apt_codename) main"
# On Linux Mint, `lsb_release -cs` returns Mint's own codename (e.g. "xia"),
# not the Ubuntu release it's built on, so a vendor repo URL built from it
# 404s. /etc/os-release exposes the real Ubuntu base as UBUNTU_CODENAME on
# Mint; on Ubuntu itself it's just the same value lsb_release -cs would
# give, so this is safe to use from either script.
get_apt_codename() {
    (
        # shellcheck disable=SC1091 # present at runtime, not in the repo
        . /etc/os-release
        echo "${UBUNTU_CODENAME:-$(lsb_release -cs)}"
    )
}

# True if an apt source of this name has already been added, so callers can
# skip re-adding it. Checks both the classic .list format and the deb822
# .sources format Ubuntu 24.04+ writes by default.
apt_source_exists() {
    local name="$1"
    if [ -e "/etc/apt/sources.list.d/${name}.list" ] || [ -e "/etc/apt/sources.list.d/${name}.sources" ]; then
        echo "Source already exists: ${name}"
        return 0
    fi
    return 1
}

# Usage: add_apt_key_repo <key-url> <keyring-path> <sources-list-name> <repo-line>
# Downloads and dearmors a GPG key to <keyring-path>, then writes
# <repo-line> - a full `deb [signed-by=...] url suite component` line - to
# /etc/apt/sources.list.d/<sources-list-name>.list. Use this for the common
# case where a vendor publishes their signing key at a URL.
add_apt_key_repo() {
    local key_url="$1" keyring="$2" list_name="$3" repo_line="$4"

    sudo install -m 0755 -d "$(dirname "$keyring")"
    curl -fsSL "$key_url" | sudo gpg --dearmor --yes -o "$keyring"
    sudo chmod a+r "$keyring"
    echo "$repo_line" | sudo tee "/etc/apt/sources.list.d/${list_name}.list" >/dev/null
}

# Usage: add_apt_keyserver_repo <key-fingerprint> <keyring-path> <sources-list-name> <repo-line>
# Same as add_apt_key_repo, but fetches the key by fingerprint from Ubuntu's
# keyserver instead - for repos that don't publish their key at a plain URL
# (e.g. a PPA added by hand rather than via `add-apt-repository ppa:...`,
# which fetches its own key automatically and doesn't need this at all).
add_apt_keyserver_repo() {
    local fingerprint="$1" keyring="$2" list_name="$3" repo_line="$4"

    sudo install -m 0755 -d "$(dirname "$keyring")"
    sudo gpg --no-default-keyring --keyring "$keyring" \
        --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$fingerprint"
    sudo chmod a+r "$keyring"
    echo "$repo_line" | sudo tee "/etc/apt/sources.list.d/${list_name}.list" >/dev/null
}
