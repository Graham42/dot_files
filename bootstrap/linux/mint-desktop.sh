#!/usr/bin/env bash

# Goals of this script:
#  - Fully configure a Linux Mint (Cinnamon edition) system.
#  - Nothing should be configured manually.
#  - Should be rerunnable to update system.
#
# Linux Mint is Ubuntu-based, so the bulk of the work is the shared
# desktop-common.sh (and apt-repo-common.sh under it). What's dropped
# compared to ubuntu-desktop.sh is GNOME-specific: there's no GNOME Shell,
# so gnome-tweaks and gnome-shell-extensions don't apply. That leaves no
# Mint-specific packages at all right now.
#
# NOTE: written ahead of Linux Mint 23's release (expected ~Dec 2026, based
# on Ubuntu 26.04) - re-check package/repo availability once it's actually
# out.

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
# no Mint-specific packages to add on top of the common set
# shellcheck disable=SC2119 # no extra packages, so no args to pass
desktop_common_install

################################################################################
# VPN
################################################################################

desktop_common_pia_vpn

################################################################################
# Keyboard
################################################################################

desktop_common_remap_keys

################################################################################
# Fonts
################################################################################

# DejaVuSansMono: the Nerd Font patched version of Cinnamon/Mint-Y's default
# monospace font (see nerd-font.sh for how to check the current default).
"$script_dir/nerd-font.sh" DejaVuSansMono
