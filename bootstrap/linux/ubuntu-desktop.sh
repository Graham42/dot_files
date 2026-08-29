#!/usr/bin/env bash

# Goals of this script:
#  - Fully configure an ubuntu system.
#  - Nothing should be configured manually.
#  - Should be rerunnable to update system.
#
# Everything shared with other apt-based desktops lives in
# desktop-common.sh; what's left here is GNOME/Ubuntu specific.

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./desktop-common.sh
source "$script_dir/desktop-common.sh"

"$script_dir/ubuntu.sh"

################################################################################
# Packages
################################################################################

desktop_common_prereqs
desktop_common_repos

# GNOME-only extras.
packages=(
    # tweak gnome settings (was gnome-tweak-tool, package renamed)
    gnome-tweaks
    # manage/run gnome shell extensions
    gnome-shell-extensions
    # fingerprint reader support: daemon (fprintd) + PAM module
    # (libpam-fprintd) for login/sudo. No GUI enrollment wired up yet -
    # run `fprintd-enroll` by hand.
    fprintd
    libpam-fprintd
)
desktop_common_install "${packages[@]}"

################################################################################
# VPN
################################################################################

desktop_common_pia_vpn

################################################################################
# Apps
################################################################################

desktop_common_obsidian
desktop_common_handy

################################################################################
# Keyboard
################################################################################

desktop_common_remap_keys

################################################################################
# Touchpad
################################################################################

desktop_common_disable_while_typing

################################################################################
# Terminal
################################################################################

# Drop-down Alacritty, opened with the Caps Lock remap above. A GNOME Shell
# extension owns the hotkey and the show/hide; the same script gives Alacritty
# its color theme.
"$script_dir/alacritty-quake.py"

################################################################################
# Fonts
################################################################################

# UbuntuMono: the Nerd Font patched version of GNOME/Yaru's default monospace
# font on Ubuntu (see nerd-font.sh for how to check the current default).
"$script_dir/nerd-font.sh" UbuntuMono

################################################################################
# GNOME settings
################################################################################

# ubuntu-desktop-26.04-settings.sh hardcodes gsettings keys/values that only
# apply to 26.04's GNOME version, and exits 1 on anything else - so it's only
# safe to run under the same version check it makes internally, not
# unconditionally like the rest of this script.
if grep -q 26.04 /etc/lsb-release; then
    "$script_dir/ubuntu-desktop-26.04-settings.sh"
fi
