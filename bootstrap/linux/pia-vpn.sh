#!/usr/bin/env bash

# Installs the Private Internet Access VPN app, following
# https://helpdesk.privateinternetaccess.com/hc/en-us/articles/46775920774043-Linux-Installing-the-PIA-App
#
# Usage: ./pia-vpn.sh [--uninstall]
#   --uninstall    Run PIA's own uninstaller (it asks for confirmation).
#
# PIA publishes no apt repo, only a Makeself self-extracting .run installer,
# so this is a download-and-run rather than another entry in
# desktop-common.sh's package list. The installer does the distro-specific
# work itself: it pulls its own dependencies (xterm, libnl, iptables, ...)
# through apt, installs to /opt/piavpn, and sets up the piavpn service.
#
# Four things about that installer are worth knowing:
#
#   - It must not be run with sudo. It refuses to start as root and calls
#     sudo itself for the steps that need it, so run this script as the
#     normal user - the same way the desktop scripts are run.
#   - It needs --nox11. Makeself's wrapper re-execs the installer inside
#     xterm when it has no tty but DISPLAY is set, which is exactly what
#     happens when this is run from a launcher or with its output piped.
#   - It ends by launching the GUI client. Logging in is manual: PIA
#     usernames look like p1234567.
#   - It only prompts in the awkward cases (an ancient /opt/pia install, an
#     architecture that doesn't match), so a normal run is unattended.
#
# There is no stable "latest" download URL to hardcode - the filename carries
# the version. https://www.privateinternetaccess.com/installer/x/download_installer_linux
# is a page whose only job is to redirect to the current build, so the
# version comes from reading the URL out of it. That also makes this
# rerunnable: an install that already matches that version is left alone,
# and an older one gets upgraded in place (the installer keeps settings).
#
# Only x86_64 and arm64 builds exist. The arm64 one is the same URL with an
# arm64 infix in the filename; there is no armhf build, so 32-bit ARM is
# skipped the way desktop-common.sh skips 1Password.
#
# Autostart is deliberately not scripted. The client owns
# ~/.config/autostart/piavpn.desktop and rewrites it from its own "Launch on
# System Startup" setting, so a file written here would just be undone.

set -euo pipefail

# Redirects to the current installer; see the header.
DOWNLOAD_PAGE="https://www.privateinternetaccess.com/installer/x/download_installer_linux"
INSTALL_DIR="/opt/piavpn"
VERSION_FILE="$INSTALL_DIR/share/version.txt"
UNINSTALLER="$INSTALL_DIR/bin/pia-uninstall.sh"

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
      sed -n '3,7p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your normal user, not root - PIA's installer refuses to run as root." >&2
  exit 1
fi

if [ "$uninstall" = true ]; then
  if [ ! -x "$UNINSTALLER" ]; then
    log "PIA is not installed - nothing to uninstall."
    exit 0
  fi
  log "Running PIA's uninstaller..."
  "$UNINSTALLER"
  exit 0
fi

# The .run is a single-architecture build, so pick the matching one. dpkg's
# name is used rather than uname's because that's what the rest of this
# directory checks against.
case "$(dpkg --print-architecture)" in
  amd64) arch_infix="" ;;
  arm64) arch_infix="arm64-" ;;
  *)
    warn "Skipping PIA: no build for $(dpkg --print-architecture), only x86_64 and arm64."
    exit 0
    ;;
esac

log "Looking up the current PIA release..."
url=$(curl -fsSL "$DOWNLOAD_PAGE" \
  | grep -oE 'https://installers\.privateinternetaccess\.com/download/pia-linux-[0-9][^"]*\.run' \
  | head -1)
if [ -z "$url" ]; then
  echo "Could not find an installer URL on $DOWNLOAD_PAGE" >&2
  exit 1
fi

url="${url/pia-linux-/pia-linux-$arch_infix}"
installer="${url##*/}"
# pia-linux-3.7.2-08420.run -> 3.7.2-08420
version="${installer%.run}"
version="${version##pia-linux-"$arch_infix"}"

# version.txt's first line is the same version with a + where the filename
# has a -, e.g. 3.7.2+08420.
if [ -r "$VERSION_FILE" ]; then
  installed=$(head -1 "$VERSION_FILE" | tr '+' '-')
  if [ "$installed" = "$version" ]; then
    log "PIA $version is already installed."
    exit 0
  fi
  log "Upgrading PIA $installed to $version..."
else
  log "Installing PIA $version..."
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

log "Downloading $installer..."
curl -fSL --progress-bar -o "$tmpdir/$installer" "$url"

# Run from the temp dir: the installer unpacks beside itself and the client
# it launches at the end inherits the working directory.
log "Running the installer (it will ask for your sudo password)..."
(cd "$tmpdir" && sh "./$installer" --nox11)

log "Done. Log in with your PIA username (p1234567) to finish setup."
