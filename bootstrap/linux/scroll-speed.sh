#!/usr/bin/env bash

# Sets how fast the touchpad scrolls. Neither GNOME nor Cinnamon puts this
# setting in their settings app, so it has to be done by hand.
#
# Usage: ./scroll-speed.sh [--factor N] [--uninstall]
#   --factor N     How fast to scroll. Lower is slower. Default: 0.25.
#                  On Wayland this goes straight to `wsf set`. On X11 it
#                  becomes a ScrollPixelDistance instead. See below.
#   --uninstall    Remove WSF, or delete the Xorg config file.
#
# Why this needs two different methods:
#
#   libinput has no scroll speed setting, and that is on purpose. It reports
#   scroll in "scroll units". It leaves the job of turning those units into
#   pixels to the program above it. That program is different on each kind of
#   session.
#
#   - On X11, that program is the xf86-input-libinput driver. It has a
#     setting called ScrollPixelDistance, so all we need is a config file.
#     There is nothing to install. Mint 22 still uses X11 by default.
#   - On Wayland, that program is mutter, and mutter has no such setting.
#     Ubuntu 26.04 only has Wayland. GNOME 50 dropped the X11 session, so
#     there is no /usr/share/xsessions at all. The one thing that works today
#     is Wayland Scroll Factor (WSF). It loads a small shim into gnome-shell
#     that scales the scroll values as they pass through.
#     https://github.com/daniel-g-carrasco/wayland-scroll-factor
#
# GNOME may fix this one day, but do not plan around it. A scroll-speed key
# was added to gsettings-desktop-schemas in June 2026 and is in the main
# branch now. Nothing reads it yet though: mutter, GNOME Control Center and
# gnome-settings-daemon have no mention of it at all, and the mutter change
# that would make it work has been open since April 2021. Check whether
# gsettings has the setting before assuming WSF is still needed.
#
# WSF does its work inside the compositor, so it covers every app: GTK, Qt,
# XWayland, snaps, and Chrome and Electron apps. Those last two have no scroll
# speed setting of their own, and there is no Chromium flag for it either.
#
# One catch. Chrome's Wayland code multiplies scroll by about 5.3 on its own.
# So Chrome, VS Code and Slack still scroll faster than GTK apps, no matter
# what you set here. Set those apps one at a time instead:
#   VS Code   editor.mouseWheelScrollSensitivity, default 1. Two more cover
#             lists and the terminal: workbench.list.* and
#             terminal.integrated.*
#   Firefox   apz.gtk.pangesture.pixel_delta_mode_multiplier, default 40.0.
#             It is not mousewheel.default.delta_multiplier_y. That one only
#             works for a real mouse wheel. Touchpad scrolling takes a
#             different path through the code and never reaches it.
#

set -euo pipefail

WSF_REPO="daniel-g-carrasco/wayland-scroll-factor"
XORG_CONF="/etc/X11/xorg.conf.d/40-touchpad-scroll.conf"
WSF_ENV_FILE="$HOME/.config/environment.d/wayland-scroll-factor.conf"

factor="0.25"
uninstall=false

function log {
  echo -e "\033[34m$*\033[0m"
}

function warn {
  echo -e "\033[33m$*\033[0m" >&2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --factor)
      factor="${2:?--factor needs a number, e.g. --factor 0.25}"
      shift 2
      ;;
    --uninstall)
      uninstall=true
      shift
      ;;
    -h | --help)
      sed -n '3,10p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

################################################################################
# Which kind of session is this?
################################################################################

# XDG_SESSION_TYPE is the easy answer, but it is empty over ssh and in a plain
# text console. So fall back to asking logind about the graphical session.
function session_type {
  if [ -n "${XDG_SESSION_TYPE:-}" ] && [ "$XDG_SESSION_TYPE" != "unspecified" ]; then
    echo "$XDG_SESSION_TYPE"
    return
  fi
  if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    echo "wayland"
    return
  fi
  local display_session type=""
  display_session=$(loginctl show-user "$USER" -p Display --value 2>/dev/null) || true
  if [ -n "$display_session" ]; then
    type=$(loginctl show-session "$display_session" -p Type --value 2>/dev/null) || true
  fi
  # Last resort. A machine with no X11 session installed has to be Wayland.
  if [ -z "$type" ] && [ ! -d /usr/share/xsessions ]; then
    type="wayland"
  fi
  echo "${type:-unknown}"
}

session=$(session_type)

################################################################################
# Wayland: Wayland Scroll Factor
################################################################################

function wsf_uninstall {
  if command -v wsf >/dev/null; then
    log "Turning WSF off..."
    wsf disable || true
    log "Removing the wayland-scroll-factor package..."
    sudo apt-get remove -y wayland-scroll-factor || true
  fi
  # `wsf disable` normally clears this file. Delete it directly as well, in
  # case the wsf program is already gone. If we skip this, a dead LD_PRELOAD
  # line gets left behind.
  if [ -f "$WSF_ENV_FILE" ]; then
    log "Removing $WSF_ENV_FILE"
    rm -f "$WSF_ENV_FILE"
    systemctl --user daemon-reexec 2>/dev/null || true
  fi
}

function wsf_setup {
  command -v gnome-shell >/dev/null || {
    warn "WSF 1.0.0 only works on GNOME with Wayland, and this is not GNOME."
    warn "That includes Cinnamon's Wayland session, so Mint 23 will need a"
    warn "different answer."
    warn ""
    warn "Log in to an X11 session and run this again. It will use the"
    warn "built-in ScrollPixelDistance setting instead."
    exit 1
  }

  if command -v wsf >/dev/null; then
    log "WSF is already installed."
  else
    local arch
    arch=$(dpkg --print-architecture)
    if [ "$arch" != "amd64" ]; then
      echo "WSF only ships an amd64 .deb, and this machine is $arch." >&2
      echo "Build it from source instead: https://github.com/$WSF_REPO" >&2
      exit 1
    fi

    log "Looking up the newest WSF release..."
    # Take whatever the newest release is, the same way nerd-font.sh does.
    # The dbgsym file has to be skipped. It ends in _amd64.deb too, and it
    # comes first in the list.
    local url
    url=$(curl -fsSL "https://api.github.com/repos/$WSF_REPO/releases/latest" |
      python3 -c '
import json, sys
arch = sys.argv[1]
for asset in json.load(sys.stdin).get("assets", []):
    name = asset["name"]
    if name.endswith("_%s.deb" % arch) and "dbgsym" not in name:
        print(asset["browser_download_url"])
        break
' "$arch")

    if [ -z "$url" ]; then
      echo "The newest release of $WSF_REPO has no ${arch} .deb in it." >&2
      echo "Check https://github.com/$WSF_REPO/releases" >&2
      exit 1
    fi

    local tmpdir
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    log "Downloading $(basename "$url")..."
    curl -fsSL -o "$tmpdir/wsf.deb" "$url"

    # This package has no install scripts of its own. Nothing actually
    # changes until `wsf enable` runs below.
    log "Installing..."
    sudo apt-get install -y "$tmpdir/wsf.deb"
  fi

  log "Setting the scroll factor to $factor..."
  wsf set "$factor"

  # This writes ~/.config/environment.d/wayland-scroll-factor.conf. systemd
  # loads that file into gnome-shell's environment at login. Do not run it
  # with sudo. It is per-user config, and it never touches
  # /etc/ld.so.preload.
  log "Turning it on..."
  wsf enable
}

################################################################################
# X11: ScrollPixelDistance
################################################################################

function xorg_uninstall {
  if [ -f "$XORG_CONF" ]; then
    log "Removing $XORG_CONF"
    sudo rm -f "$XORG_CONF"
  fi
}

function xorg_setup {
  # ScrollPixelDistance is how far a finger has to move for one wheel click.
  # The default is 15, so a bigger number scrolls slower. That is backwards
  # from how the WSF factor works. Clamp the result, because the driver
  # ignores values that are far out of range.
  local distance
  distance=$(python3 -c '
import sys
print(max(10, min(100, round(15 / float(sys.argv[1])))))
' "$factor")

  log "Writing $XORG_CONF, with a distance of $distance..."
  sudo mkdir -p "$(dirname "$XORG_CONF")"
  sudo tee "$XORG_CONF" >/dev/null <<EOF
# Written by dot_files/bootstrap/linux/scroll-speed.sh. Any edits here will
# be overwritten. The default distance is 15. Bigger scrolls slower.
Section "InputClass"
    Identifier "touchpad scroll speed"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "ScrollPixelDistance" "$distance"
EndSection
EOF

  # Apply it right now as well, so there is no need to log out.
  if command -v xinput >/dev/null; then
    local prop="libinput Scrolling Pixel Distance"
    while read -r id; do
      xinput set-prop "$id" "$prop" "$distance" 2>/dev/null || true
    done < <(xinput list --id-only 2>/dev/null || true)
  fi
}

################################################################################
# Go
################################################################################

if $uninstall; then
  wsf_uninstall
  xorg_uninstall
  log "Done. Restart the computer to finish undoing this."
  exit 0
fi

case "$session" in
  wayland)
    log "This is a Wayland session, so using Wayland Scroll Factor."
    wsf_setup
    log ""
    warn "Restart the computer to make the new scroll speed take effect."
    log ""
    log "After the restart, check that it worked:"
    log "    wsf doctor"
    log "You want the line 'gnome-shell library mapped: yes'."
    log ""
    log "Two things in there look broken but are fine. \$LD_PRELOAD will be"
    log "empty, and it will say 'user manager LD_PRELOAD: not set'. WSF takes"
    log "itself back out of the environment once it has loaded, so that other"
    log "programs do not inherit it."
    log ""
    log "To change the speed later, with no restart: wsf set 0.35"
    log "Lower is slower."
    ;;
  x11)
    log "This is an X11 session, so using the libinput driver's own setting."
    xorg_setup
    log ""
    log "It is live in this session now, and the config file makes it stick."
    ;;
  *)
    echo "Could not tell if this is X11 or Wayland. Got: $session" >&2
    echo "Run this inside a desktop session, not over ssh." >&2
    exit 1
    ;;
esac
