#!/usr/bin/env bash

# If we're not running 26.04, these settings are probably all different
if ! grep 26.04 /etc/lsb-release; then
  echo "This doesn't look like 26.04"
  exit 1
fi

################################################################################
# To find how to set more settings run `dconf watch /` and then change the
# setting in the GUI.
################################################################################

# make Alt + Tab switch windows instead of applications
# Source: https://people.gnome.org/~federico/blog/alt-tab.html
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Super><Shift>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward  "['<Alt><Shift>Tab']"

# Customize top bar appearance
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-weekday true

# Use blue light filter
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

# Shrink the dock icons (default is 48px)
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 36

################################################################################
# 1Password
################################################################################

# Global hotkey for Quick Access. GNOME on Wayland doesn't let apps register
# their own global shortcuts (unlike X11, where this is set in 1Password's
# own Settings > General), so it has to be done at the DE level instead.
# See https://support.1password.com/keyboard-shortcuts/?linux
#
# Uses a dedicated relocatable-schema path rather than reusing/renumbering
# an existing "customN" slot, and merges into custom-keybindings rather than
# overwriting it, so this stays safe to rerun and doesn't clobber any other
# custom bindings already set.
op_keybinding_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/1password-quick-access/"

existing_keybindings="$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)"
if [[ "$existing_keybindings" != *"$op_keybinding_path"* ]]; then
    if [ "$existing_keybindings" = "@as []" ]; then
        new_keybindings="['$op_keybinding_path']"
    else
        new_keybindings="${existing_keybindings%]}, '$op_keybinding_path']"
    fi
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$new_keybindings"
fi

op_keybinding_schema="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$op_keybinding_path"
gsettings set "$op_keybinding_schema" name '1Password Quick Access'
gsettings set "$op_keybinding_schema" command '1password --quick-access'
gsettings set "$op_keybinding_schema" binding '<Primary><Shift>space'
