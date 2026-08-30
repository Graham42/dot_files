#!/usr/bin/env bash

# Installs stuck-key-indicator (https://github.com/Graham42/stuck-key-indicator),
# a tray icon that warns when a laptop's Left Alt key is physically stuck
# down (grey ring up, amber triangle pressed, red blinking square once it's
# been held for 1.5s).
#
# Usage: ./stuck-key-indicator.sh [--uninstall]
#   --uninstall   Run upstream's own uninstall.sh: stops/disables the
#                 service and removes the binaries, service unit and
#                 autostart entry. Leaves the git checkout in place.
#
# Not wired into ubuntu-desktop.sh/mint-desktop.sh - this is for the one
# machine with the sticky key, not every machine. Run it by hand:
#   ./bootstrap/linux/stuck-key-indicator.sh
#
# Unlike obsidian.sh/handy.sh, upstream publishes no releases or .deb - only
# source, built via its own install.sh - so this clones/updates a checkout
# and builds instead of downloading a prebuilt package. Everything it needs
# is pure Rust: no system dev packages beyond the toolchain ubuntu.sh already
# installs via rustup.
#
# What install.sh sets up:
#   - alt-state-daemon: installed to /usr/local/bin, run as a systemd
#     service (DynamicUser, input group only, heavily sandboxed - see
#     upstream's systemd/alt-state.service) that reads /dev/input for
#     KEY_LEFTALT and publishes state on a unix socket. This is the only
#     part that touches /dev/input, so nothing here needs your user added to
#     the input group (a full keylogger's worth of access).
#   - alt-indicator: the unprivileged tray client reading that socket,
#     installed to /usr/local/bin and autostarted via
#     ~/.config/autostart/alt-indicator.desktop
#
# The tray icon needs a StatusNotifierItem host to show up in. Cinnamon has
# one built in; GNOME needs the AppIndicator extension turned on by hand
# (Extensions app) - the same manual step 1Password's tray icon needs (see
# desktop-common.sh) even though ubuntu-desktop.sh already installs the
# gnome-shell-extensions package.

set -euo pipefail

REPO_URL="https://github.com/Graham42/stuck-key-indicator.git"
# Kept after install because it is the uninstaller: --uninstall runs
# upstream's uninstall.sh out of this checkout. Delete it and the installed
# service has nothing left to remove it.
SRC_DIR="$HOME/.local/src/stuck-key-indicator"

uninstall=false

function log {
  echo -e "\033[34m$*\033[0m"
}

function warn {
  echo -e "\033[33m$*\033[0m" >&2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --uninstall)
      uninstall=true
      shift
      ;;
    -h | --help)
      # Keep this range in sync with the Usage block above.
      sed -n '3,11p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [ "$uninstall" = true ]; then
  if [ ! -d "$SRC_DIR" ]; then
    log "stuck-key-indicator checkout not found at $SRC_DIR - nothing to uninstall."
    exit 0
  fi
  log "Uninstalling stuck-key-indicator..."
  (cd "$SRC_DIR" && ./uninstall.sh)
  exit 0
fi

if ! command -v cargo &>/dev/null; then
  echo "cargo not found - run ubuntu.sh (or install Rust via https://rustup.rs) first" >&2
  exit 1
fi

if [ -d "$SRC_DIR/.git" ]; then
  log "Updating stuck-key-indicator checkout..."
  git -C "$SRC_DIR" pull --ff-only
else
  log "Cloning stuck-key-indicator..."
  mkdir -p "$(dirname "$SRC_DIR")"
  git clone "$REPO_URL" "$SRC_DIR"
fi

log "Building and installing - takes a while (it will ask for your sudo password)..."
(cd "$SRC_DIR" && ./install.sh)

log "The daemon is running now; the tray client only autostarts at next login."
log "Start it for this session with: alt-indicator &"
warn "On GNOME the icon stays hidden until you enable AppIndicator (Extensions app)."
