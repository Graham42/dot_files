#!/usr/bin/env bash

# Sets up a Guake-style drop-down Alacritty on GNOME: press one key, a terminal
# slides down from the top; press it again, it goes away.
#
# Usage: ./alacritty-quake.sh [--shortcut ACCEL] [--uninstall]
#   --shortcut ACCEL   GTK accelerator for the toggle. Default: XF86Launch5,
#                      which is what the F14 that remap-keys.sh puts on Caps
#                      Lock actually sends - xkb renames F13-F18 to XF86
#                      keysyms, so "F14" as an accelerator never fires.
#                      Other examples: '<Super>Return', '<Super>grave', 'F12'.
#   --uninstall        Undo everything below except the alacritty package.
#
# Why it's built this way:
#
#   - Wayland gives applications no global hotkeys - the compositor owns the
#     keyboard - so the hotkey has to be registered with GNOME, not Alacritty.
#   - Alacritty will never grow a drop-down mode of its own; upstream closed
#     that request as wontfix (alacritty/alacritty#1119).
#   - The usual X11 answers (tdrop, xdotool, wmctrl) are dead here: GNOME 50
#     removed the X11 session entirely, so there's no /usr/share/xsessions.
#
#   That leaves a GNOME Shell extension owning both the hotkey and the
#   show/hide. Quake Terminal is the maintained one (declares GNOME 45-50).
#
# The drop-down gets its own app id (--class) and its own config file rather
# than reusing the stock Alacritty.desktop, because the extension adopts
# `app.get_windows()[0]` of whatever app it's pointed at - aimed at plain
# Alacritty it would grab an ordinary terminal window you already had open.

set -euo pipefail

EXTENSION_UUID="quake-terminal@diegodario88.github.io"
EXTENSION_PAGE="https://extensions.gnome.org/extension/6307/quake-terminal/"
APP_ID="alacritty-quake"
DESKTOP_FILE="$HOME/.local/share/applications/${APP_ID}.desktop"
QUAKE_CONFIG="$HOME/.config/alacritty/quake.toml"
MAIN_CONFIG="$HOME/.config/alacritty/alacritty.toml"
SCHEMA_ID="org.gnome.shell.extensions.quake-terminal"

# Drop-down geometry. Sizes are percentages of the monitor's work area - the
# screen minus the top bar and dock - not of the whole screen. The extension
# re-applies these every time the window is shown, so resizing the window by
# hand never sticks; this is the only durable place to set it.
VERTICAL_SIZE=100        # height, % (the prefs UI allows 10-100)
HORIZONTAL_SIZE=100      # width, %  (the prefs UI allows 30-100)
HORIZONTAL_ALIGNMENT=2   # 0 = left, 1 = right, 2 = center
# Duration of the slide-down animation in milliseconds. 0 is a supported value
# (the prefs spinner goes 0-500), not a hack - the window just snaps into place.
ANIMATION_TIME=0

shortcut="XF86Launch5"
uninstall=false

function log {
  echo -e "\033[34m$*\033[0m"
}

function warn {
  echo -e "\033[33m$*\033[0m" >&2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --shortcut)
      shortcut="${2:?--shortcut needs an accelerator, e.g. --shortcut '<Super>Return'}"
      shift 2
      ;;
    --uninstall)
      uninstall=true
      shift
      ;;
    -h | --help)
      sed -n '3,12p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

command -v gnome-shell >/dev/null || {
  echo "This needs GNOME Shell - the extension it relies on is GNOME-only." >&2
  exit 1
}

# Where the extension's gsettings schema lives. Local installs (what
# `gnome-extensions install` does) land in ~/.local; ask gnome-extensions
# where it actually is in case it was installed system-wide instead.
function schema_dir {
  local dir="$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID/schemas"
  if [ ! -d "$dir" ]; then
    local path
    path=$(gnome-extensions info "$EXTENSION_UUID" 2>/dev/null |
      sed -n 's/^ *Path: *//p') || true
    [ -n "$path" ] && dir="$path/schemas"
  fi
  echo "$dir"
}

################################################################################
# Uninstall
################################################################################

if $uninstall; then
  if gnome-extensions info "$EXTENSION_UUID" >/dev/null 2>&1; then
    log "Removing the Quake Terminal extension..."
    gnome-extensions disable "$EXTENSION_UUID" 2>/dev/null || true
    gnome-extensions uninstall "$EXTENSION_UUID" || true
  fi
  # `gnome-extensions disable` only touches this key when the shell knows
  # about the extension, so clear it directly too.
  enabled=$(gsettings get org.gnome.shell enabled-extensions)
  if [[ "$enabled" == *"'$EXTENSION_UUID'"* ]]; then
    gsettings set org.gnome.shell enabled-extensions \
      "$(echo "$enabled" | sed -e "s/'$EXTENSION_UUID', \?//" -e "s/, \?'$EXTENSION_UUID'//" -e "s/\['$EXTENSION_UUID'\]/@as []/")"
  fi
  for f in "$DESKTOP_FILE" "$QUAKE_CONFIG"; do
    [ -f "$f" ] && log "Removing $f" && rm -f "$f"
  done
  command -v update-desktop-database >/dev/null &&
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
  log "Done. The alacritty package was left installed; remove it with 'sudo apt remove alacritty'."
  exit 0
fi

################################################################################
# Alacritty
################################################################################

if command -v alacritty >/dev/null; then
  log "Alacritty already installed ($(alacritty --version))"
else
  log "Installing alacritty..."
  sudo apt-get install -y alacritty
fi

################################################################################
# Config for the drop-down instance
################################################################################

# A separate config file keeps the drop-down's look (no titlebar, no padding
# fighting the animation) from leaking into ordinary Alacritty windows. The
# import of the main config is unconditional on purpose: Alacritty skips
# missing imports, so this works whether or not alacritty.toml exists yet.
mkdir -p "$(dirname "$QUAKE_CONFIG")"
if [ -f "$QUAKE_CONFIG" ]; then
  log "Keeping existing $QUAKE_CONFIG"
else
  log "Writing $QUAKE_CONFIG"
  cat > "$QUAKE_CONFIG" <<EOF
# Config for the drop-down Alacritty instance (see alacritty-quake.sh).
# Everything else is inherited from the main config; edit this file freely,
# the setup script won't overwrite it.

[general]
import = ["$MAIN_CONFIG"]

[window]
# The extension positions and sizes the window itself, so a titlebar is just
# lost rows.
decorations = "none"
EOF
fi

################################################################################
# A .desktop entry, so the drop-down is its own app as far as GNOME is concerned
################################################################################

# Requirements this file has to satisfy, both from the extension's app picker
# (src/prefs.js): Categories must contain "terminal", and it must not be
# NoDisplay, or it can't be selected in the preferences UI. The script sets
# the app via gsettings below anyway, but the picker should still work.
log "Writing $DESKTOP_FILE"
mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Alacritty (Quake)
Comment=Alacritty instance dedicated to the drop-down terminal
Exec=alacritty --class $APP_ID --config-file $QUAKE_CONFIG
Icon=Alacritty
Terminal=false
Categories=System;TerminalEmulator;
StartupWMClass=$APP_ID
EOF
command -v update-desktop-database >/dev/null &&
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

################################################################################
# The extension
################################################################################

fresh_install=false
if gnome-extensions info "$EXTENSION_UUID" >/dev/null 2>&1; then
  log "Quake Terminal extension already installed"
elif [ -d "$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID" ]; then
  # Installed on disk but the running shell hasn't picked it up yet - that's
  # this script having been run once already without a re-login.
  log "Quake Terminal extension already installed (pending a session restart)"
  fresh_install=true
else
  shell_version=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)
  log "Fetching Quake Terminal for GNOME Shell $shell_version..."

  # extensions.gnome.org serves a different build per shell version, so ask
  # the API which one this machine needs rather than guessing a URL.
  download_path=$(curl -fsSL \
    "https://extensions.gnome.org/extension-info/?uuid=${EXTENSION_UUID}&shell_version=${shell_version}" |
    python3 -c 'import json,sys; print(json.load(sys.stdin).get("download_url") or "")')

  if [ -z "$download_path" ]; then
    echo "No Quake Terminal build for GNOME Shell $shell_version." >&2
    echo "Check $EXTENSION_PAGE for which versions it supports." >&2
    exit 1
  fi

  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  curl -fsSL -o "$tmpdir/quake-terminal.zip" "https://extensions.gnome.org${download_path}"
  gnome-extensions install --force "$tmpdir/quake-terminal.zip"
  fresh_install=true
  log "Installed."
fi

# On Wayland the shell can't be restarted in place, so a just-installed
# extension isn't enableable over D-Bus yet. Writing the gsettings key
# directly gets it enabled at next login either way.
if gnome-extensions enable "$EXTENSION_UUID" 2>/dev/null; then
  log "Extension enabled"
else
  enabled=$(gsettings get org.gnome.shell enabled-extensions)
  if [[ "$enabled" == *"'$EXTENSION_UUID'"* ]]; then
    log "Extension already queued to enable at next login"
  else
    if [ "$enabled" = "@as []" ]; then
      gsettings set org.gnome.shell enabled-extensions "['$EXTENSION_UUID']"
    else
      gsettings set org.gnome.shell enabled-extensions "${enabled%]}, '$EXTENSION_UUID']"
    fi
    log "Extension will be enabled at next login"
  fi
fi

################################################################################
# Extension settings
################################################################################

schemas=$(schema_dir)
if [ ! -d "$schemas" ]; then
  echo "Can't find the extension's schemas (looked in $schemas)" >&2
  exit 1
fi
# The packaged extension ships gschemas.compiled, but a source checkout may not.
if [ ! -f "$schemas/gschemas.compiled" ] && command -v glib-compile-schemas >/dev/null; then
  glib-compile-schemas "$schemas"
fi

log "Pointing the extension at $APP_ID, bound to $shortcut"
gsettings --schemadir "$schemas" set "$SCHEMA_ID" terminal-id "$(basename "$DESKTOP_FILE")"
gsettings --schemadir "$schemas" set "$SCHEMA_ID" terminal-shortcut "['$shortcut']"

# Re-applied on every run, so tweaks made in the Extensions app get reverted
# the next time this runs - change the values at the top of this script instead.
log "Setting geometry (${HORIZONTAL_SIZE}% x ${VERTICAL_SIZE}%) and animation (${ANIMATION_TIME}ms)"
gsettings --schemadir "$schemas" set "$SCHEMA_ID" vertical-size "$VERTICAL_SIZE"
gsettings --schemadir "$schemas" set "$SCHEMA_ID" horizontal-size "$HORIZONTAL_SIZE"
gsettings --schemadir "$schemas" set "$SCHEMA_ID" horizontal-alignment "$HORIZONTAL_ALIGNMENT"
gsettings --schemadir "$schemas" set "$SCHEMA_ID" animation-time "$ANIMATION_TIME"

################################################################################
# What's left to do by hand
################################################################################

if [ "$shortcut" = "XF86Launch5" ] && ! grep -qs 'f14' /etc/keyd/default.conf; then
  warn ""
  warn "Heads up: the shortcut is XF86Launch5, which is what F14 sends, but no"
  warn "keyd config maps anything to f14 - so no key on the keyboard will"
  warn "trigger it. Either run ./remap-keys.sh to put F14 on Caps Lock, or"
  warn "re-run this with e.g."
  warn "    $0 --shortcut '<Super>grave'"
fi

if $fresh_install; then
  log ""
  log "Log out and back in to load the extension (Wayland can't restart the shell in place)."
  log "Then press $shortcut."
else
  log ""
  log "Done - press $shortcut."
fi
log "Everything this script doesn't set (monitor choice, auto-hide, always-on-top)"
log "is in the Extensions app, or:"
log "    gsettings --schemadir $schemas list-recursively $SCHEMA_ID"
