#!/usr/bin/env bash

# Goals of this script:
#  - Fully configure an ubuntu system.
#  - Nothing should be configured manually.
#  - Should be rerunnable to update system.
#
# Everything shared with other apt-based desktops lives in
# desktop-common.sh; what's left here is GNOME/Ubuntu specific.

set -euo pipefail
set -x

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
)
desktop_common_install "${packages[@]}"

################################################################################
# VPN
################################################################################

desktop_common_pia_vpn

################################################################################
# Keyboard
################################################################################

desktop_common_remap_keys

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
