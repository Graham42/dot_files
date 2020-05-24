#!/usr/bin/env bash

set -ex
set -o pipefail

################################################################################
# To find how to set more settings run `dconf watch /` and then change the
# setting in the GUI.
################################################################################

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

# config to run docker without root
sudo gpasswd -a graham docker

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

