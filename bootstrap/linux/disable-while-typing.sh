#!/usr/bin/env bash

# Makes sure the touchpad ignores itself while you're on the keyboard, so a
# resting palm or thumb doesn't move the pointer or click something.
#
# Usage: ./disable-while-typing.sh [--off] [--status]
#   --off      Turn it off instead of on.
#   --status   Print the current setting and exit. No changes made.
#
# This is libinput's own disable-while-typing (DWT) feature, on by default
# for internal touchpads - so most of the time this script has nothing to
# do. It earns its place for two reasons: it's a real setting someone can
# (and occasionally does, by accident) switch off, and rerunning this after
# that happens is one command instead of hunting through Settings again.
#
# DWT is exposed through a gsettings key, and the schema differs by desktop:
#   - GNOME (Ubuntu):   org.gnome.desktop.peripherals.touchpad
#   - Cinnamon (Mint):  org.cinnamon.settings-daemon.peripherals.touchpad
# Cinnamon forked gnome-settings-daemon years ago and still mirrors most of
# its schema layout under org.cinnamon instead of org.gnome. Both desktops
# also show this as a checkbox in their own Settings app - Mouse & Touchpad
# on GNOME, Mouse and Touchpad on Cinnamon - so this script is just a
# scriptable, rerunnable version of that same checkbox.
#
# This is NOT the other thing people call "palm rejection": a palm landing
# on the touchpad while you're actively using it (not typing). That's
# handled by libinput's own edge/pressure heuristics, tuned per touchpad
# model via its quirks database - there is no desktop setting for it, and
# it isn't something a general script can fix. If that's the actual
# problem, it needs `libinput measure touchpad-size` and a hardware-specific
# quirks override, not this script.
#
# Also sets disable-while-trackpointing (DWTP - disables the touchpad while
# the TrackPoint is in use) where the schema has it, since that's the other
# half of "stop the touchpad from getting in the way" on a ThinkPad. This is
# newer than DWT and not guaranteed to exist on every schema version, so it's
# skipped with a warning rather than failing the whole script.

set -euo pipefail

DWT_KEY="disable-while-typing"
DWTP_KEY="disable-while-trackpointing"

value="true"
status_only=false

function log {
  echo -e "\033[34m$*\033[0m"
}

function warn {
  echo -e "\033[33m$*\033[0m" >&2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --off)
      value="false"
      shift
      ;;
    --status)
      status_only=true
      shift
      ;;
    -h | --help)
      sed -n '3,10p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

################################################################################
# Which desktop, and which schema does it use?
################################################################################

function detect_schema {
  local desktop="${XDG_CURRENT_DESKTOP:-}"
  case "$desktop" in
    *GNOME*)
      echo "org.gnome.desktop.peripherals.touchpad"
      return
      ;;
    *Cinnamon*)
      # Matches both "Cinnamon" and Mint's "X-Cinnamon".
      echo "org.cinnamon.settings-daemon.peripherals.touchpad"
      return
      ;;
  esac
  # XDG_CURRENT_DESKTOP is empty over ssh and in some display managers. Fall
  # back to whichever session binary is actually on disk.
  if command -v cinnamon >/dev/null; then
    echo "org.cinnamon.settings-daemon.peripherals.touchpad"
  elif command -v gnome-shell >/dev/null; then
    echo "org.gnome.desktop.peripherals.touchpad"
  else
    echo ""
  fi
}

schema=$(detect_schema)

if [ -z "$schema" ]; then
  echo "Could not tell if this is GNOME or Cinnamon." >&2
  echo "Run this inside a desktop session, not over ssh." >&2
  exit 1
fi

if ! gsettings list-schemas | grep -qx "$schema"; then
  echo "Schema not found: $schema" >&2
  echo "Is gsettings-desktop-schemas (GNOME) or cinnamon-settings-daemon" >&2
  echo "(Cinnamon) installed?" >&2
  exit 1
fi

################################################################################
# Status
################################################################################

if $status_only; then
  # Plain key: value, no color codes - unlike the rest of this script, this
  # output is meant to be checked by something other than a person reading
  # the terminal (e.g. the check-bootstrap skill), so keep it undecorated.
  echo "schema: $schema"
  echo "$DWT_KEY: $(gsettings get "$schema" "$DWT_KEY")"
  if gsettings list-keys "$schema" | grep -qx "$DWTP_KEY"; then
    echo "$DWTP_KEY: $(gsettings get "$schema" "$DWTP_KEY")"
  else
    echo "$DWTP_KEY: not on this schema"
  fi
  exit 0
fi

################################################################################
# Set it
################################################################################

log "Setting $DWT_KEY to $value on $schema..."
gsettings set "$schema" "$DWT_KEY" "$value"

if gsettings list-keys "$schema" | grep -qx "$DWTP_KEY"; then
  log "Setting $DWTP_KEY to $value on $schema..."
  gsettings set "$schema" "$DWTP_KEY" "$value"
else
  warn "$DWTP_KEY isn't on this schema - skipping. Nothing to worry about,"
  warn "just an older gnome-settings-daemon/cinnamon-settings-daemon."
fi

log ""
log "Done. This takes effect immediately, no restart needed."
log "Check it took with: $0 --status"
