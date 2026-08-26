#!/usr/bin/env bash

# Remaps Caps Lock to F14 using keyd, so it can drive the global drop-down
# terminal shortcut (see alacritty-quake.py) without burning a real key.
#
# Usage: ./remap-keys.sh [--from KEY] [--to KEY] [--uninstall]
#   --from KEY     Key to remap. Default: capslock.
#   --to KEY       What that key should send instead. Default: f14.
#   --uninstall    Remove the config this wrote and stop the daemon.
#
# Why keyd rather than the desktop's own keyboard settings:
#
#   keyd remaps at the kernel input level - it grabs the evdev device and
#   replays events through a uinput device - so one config covers X11,
#   Wayland and plain TTYs alike. The old answer, editing files under
#   /usr/share/X11/xkb/, is X11-only and gets reverted whenever
#   xkb-data/xkeyboard-config is updated. GNOME and Cinnamon both expose Caps
#   Lock "behaviour" options, but neither can send an F13-and-up key.
#
# Why F14, when F13 is the usual pick for this:
#
#   None of F13 to F18 arrive under their own name. xkb rewrites them into
#   XF86 keysyms on the way past: F13 becomes XF86Tools, F14 becomes
#   XF86Launch5, F15 XF86Launch6, and so on. GNOME has XF86Tools wired to
#   open Settings, and that binding lives in a gsettings key the Settings app
#   does not show (media-keys control-center-static), so Caps Lock on F13
#   just opens Settings. Nothing uses XF86Launch5.
#
#   The catch that follows: a shortcut has to be set to XF86Launch5, not to
#   F14, or it will never fire. To see what a key really sends:
#       xkbcomp "$DISPLAY" - | grep -A1 "key <FK14>"
#
# Where the package comes from is the one thing that differs per distro:
#
#   - Ubuntu 26.04, and Mint 23 which is built on it: keyd is in universe
#     (it landed in 25.04), so a plain apt-get install is enough.
#   - Mint 22, on the Ubuntu 24.04 base: 24.04 predates that, so the
#     keyd-team PPA gets added first. That PPA publishes for noble but not
#     for resolute, so it is not a fallback for the releases above - each
#     route only works where it works.
#
#   The choice is made by asking apt whether it has a candidate, not by
#   matching release names, so this keeps working as releases move on.
#
# The binary is keyd.rvaiya rather than keyd on both routes: Debian renamed
# it because `keyd` collides with a utility in the onak package
# (https://bugs.debian.org/1098982), and the Ubuntu archive package and the
# PPA are both that same Debian package. The service is still keyd.service.
#
# Escape hatch: keyd owns the primary input device, so a bad config can leave
# the keyboard unusable. Pressing backspace+escape+enter together is keyd's
# panic sequence and kills the daemon.

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./apt-repo-common.sh
source "$script_dir/apt-repo-common.sh"

KEYD_CONF="/etc/keyd/default.conf"
# Written into the config so a rerun can tell its own file from one that was
# put there by hand, and leave the hand-written one alone.
CONF_MARKER="Managed by dot_files/bootstrap/linux/remap-keys.sh"
PPA_FINGERPRINT="67D33FE29A58DA9441D20A9DCD9F79EC6A8AFB2F"
PPA_KEYRING="/etc/apt/keyrings/keyd.gpg"

from="capslock"
to="f14"
uninstall=false
# Set by install_keyd once the package is on disk.
bin=""

function log {
  echo -e "\033[34m$*\033[0m"
}

function warn {
  echo -e "\033[33m$*\033[0m" >&2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --from)
      from="${2:?--from needs a key name, e.g. --from capslock}"
      shift 2
      ;;
    --to)
      to="${2:?--to needs a key name, e.g. --to f14}"
      shift 2
      ;;
    --uninstall)
      uninstall=true
      shift
      ;;
    -h | --help)
      sed -n '3,9p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

################################################################################
# Installing keyd
################################################################################

# Echoes the keyd executable's name, or nothing if it isn't installed. See the
# header for why there are two names to look for.
function keyd_bin {
  if command -v keyd.rvaiya >/dev/null; then
    echo keyd.rvaiya
  elif command -v keyd >/dev/null; then
    echo keyd
  fi
}

# True when this machine's apt already knows about keyd, i.e. it's a release
# new enough to have it in universe and no PPA is needed.
function keyd_in_apt {
  local candidate
  candidate=$(apt-cache policy keyd 2>/dev/null | awk '/^ *Candidate:/ { print $2 }')
  [ -n "$candidate" ] && [ "$candidate" != "(none)" ]
}

function add_keyd_ppa {
  # add-apt-repository ppa:keyd-team/ppa would also work, but adding it by
  # hand keeps this consistent with the other repos in this directory and
  # pins the suite to get_apt_codename - the Ubuntu codename, which is what
  # the PPA publishes, rather than Mint's own.
  if apt_source_exists keyd; then
    return 0
  fi
  if grep -rqs keyd-team /etc/apt/sources.list.d/; then
    echo "Source already exists: keyd-team PPA"
    return 0
  fi

  log "Adding ppa:keyd-team/ppa..."
  add_apt_keyserver_repo \
    "$PPA_FINGERPRINT" \
    "$PPA_KEYRING" \
    keyd \
    "deb [signed-by=$PPA_KEYRING] https://ppa.launchpadcontent.net/keyd-team/ppa/ubuntu $(get_apt_codename) main"
  sudo apt-get update
}

function install_keyd {
  if [ -n "$(keyd_bin)" ]; then
    log "keyd already installed"
  else
    if ! keyd_in_apt; then
      log "No keyd in apt on this release - falling back to the PPA."
      add_keyd_ppa
    fi
    log "Installing keyd..."
    sudo apt-get install -y keyd
  fi

  bin=$(keyd_bin)
  if [ -z "$bin" ]; then
    echo "keyd installed but neither keyd.rvaiya nor keyd is on PATH." >&2
    exit 1
  fi

  # The package's postinst enables and starts the service itself, so this is
  # usually a no-op - it's here for machines where it was stopped by hand, or
  # by a previous --uninstall.
  log "Enabling keyd.service..."
  sudo systemctl enable --now keyd
}

################################################################################
# The config
################################################################################

# keyd refuses to load a config with an unknown key name, and a refused config
# means no remap at all, so check the names against keyd's own list first.
function check_key_name {
  local key="$1"
  if "$bin" list-keys 2>/dev/null | grep -qx -- "$key"; then
    return 0
  fi
  echo "Not a key keyd knows about: $key" >&2
  echo "Run \`$bin list-keys\` for the full list." >&2
  exit 1
}

# What xkb renames the F13-and-up keys to. A shortcut has to be set to this
# name rather than the F-key's own, so the closing message can say so.
function keysym_for {
  case "$1" in
    f13) echo XF86Tools ;;
    f14) echo XF86Launch5 ;;
    f15) echo XF86Launch6 ;;
    f16) echo XF86Launch7 ;;
    f17) echo XF86Launch8 ;;
    f18) echo XF86Launch9 ;;
  esac
}

function write_config {
  if [ -f "$KEYD_CONF" ] && ! grep -q "$CONF_MARKER" "$KEYD_CONF"; then
    warn "$KEYD_CONF wasn't written by this script - backing it up to"
    warn "$KEYD_CONF.bak before overwriting."
    sudo cp -a "$KEYD_CONF" "$KEYD_CONF.bak"
  fi

  log "Writing $KEYD_CONF ($from = $to)..."
  sudo install -m 0755 -d "$(dirname "$KEYD_CONF")"
  sudo tee "$KEYD_CONF" >/dev/null <<EOF
# $CONF_MARKER - edits will be overwritten.

# Which keyboards this applies to. * is all of them; to target one, use the
# vendor:product id that \`$bin monitor\` prints for it.
[ids]
*

# The base layer - these bindings apply unconditionally.
[main]
$from = $to
EOF

  log "Reloading keyd..."
  sudo "$bin" reload
}

function do_uninstall {
  bin=$(keyd_bin)

  if [ -f "$KEYD_CONF" ]; then
    if grep -q "$CONF_MARKER" "$KEYD_CONF"; then
      log "Removing $KEYD_CONF"
      sudo rm -f "$KEYD_CONF"
    else
      warn "Leaving $KEYD_CONF alone - it wasn't written by this script."
    fi
  fi

  if [ -z "$bin" ]; then
    log "keyd isn't installed - nothing else to undo."
    return 0
  fi

  # Only stop the daemon if it has no work left. Another config in /etc/keyd
  # means someone is remapping something else through it.
  if compgen -G "/etc/keyd/*.conf" >/dev/null; then
    log "Other configs remain in /etc/keyd - reloading rather than stopping."
    sudo "$bin" reload
  else
    log "Stopping and disabling keyd.service..."
    sudo systemctl disable --now keyd
  fi

  log "The keyd package is left installed - apt-get remove keyd to drop it."
}

################################################################################
# Go
################################################################################

if $uninstall; then
  do_uninstall
  log "Done. The remap stops with the daemon - no restart needed."
  exit 0
fi

install_keyd
check_key_name "$from"
check_key_name "$to"
write_config

log ""
log "Done - $from sends $to now, in X11, Wayland and TTYs alike."

keysym=$(keysym_for "$to")
if [ -n "$keysym" ]; then
  log ""
  log "The desktop sees $to as $keysym - xkb renames these keys. Use that"
  log "name, not $to, when you bind a shortcut to it."
fi

log ""
log "Check it took with:"
log "    sudo $bin monitor"
log "Press $from and look for '$to' in the output; Ctrl+C to stop. If it"
log "didn't take, keyd logs config errors to:"
log "    sudo journalctl -eu keyd"
log ""
log "If a remap ever leaves the keyboard unusable, press backspace, escape and"
log "enter together - that's keyd's panic sequence and it kills the daemon."
