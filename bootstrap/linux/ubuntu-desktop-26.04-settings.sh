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
