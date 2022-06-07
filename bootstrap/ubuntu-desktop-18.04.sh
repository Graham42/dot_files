#!/usr/bin/env bash

# If we're not running 18.04, these settings are probably all different
if ! grep 18.04 /etc/lsb-release; then
  echo "This doesn't look like 18.04"
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

# Hide desktop icons
gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.gnome.shell.extensions.desktop-icons show-home false
gsettings set org.gnome.shell.extensions.desktop-icons show-trash false

# Customize top bar appearance
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-weekday true

# Use blue light filter
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

# Alway launch a new window instead of switching to the open one
gsettings set org.gnome.shell enabled-extensions "['launch-new-instance@gnome-shell-extensions.gcampax.github.com']"

# Permanently hide the Ubuntu dock extension
# Dock always visible
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
# Dock shown on mouse over
gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
# Dock dodges windows
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false

# disable Nautilus (file explorer) fancy but useless search. This almost makes
# it feel like typeahead exists.
gsettings set org.gnome.nautilus.preferences fts-enabled false
gsettings set org.gnome.nautilus.preferences recursive-search 'never'
