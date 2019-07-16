#!/usr/bin/env bash

set -ex
set -o pipefail

# need to update index for locate command
sudo updatedb
# set chrome at default browser
CHROME_DESKTOP=$(locate -r 'google-chrome\.desktop$' | head -n1 | xargs basename)
xdg-settings set default-web-browser "$CHROME_DESKTOP"

# To find how to set more settings run `dconf watch /` and then change the
# setting in the GUI.

# make Alt + Tab switch windows instead of applications
# Source: https://people.gnome.org/~federico/blog/alt-tab.html
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab', '<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward  "['<Alt><Shift>Tab', '<Super><Shift>Tab']"

# Hide desktop icons
gsettings set org.gnome.desktop.background show-desktop-icons false

# Customize top bar appearance
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface clock-show-date true

# Use blue light filter
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

# Alway launch a new window instead of switching to the open one
gsettings set org.gnome.shell enabled-extensions "['launch-new-instance@gnome-shell-extensions.gcampax.github.com']"

# Fix color on boot screen
sudo sed -i -E 's!^Window.SetBackgroundTopColor.*$!Window.SetBackgroundTopColor (0, 0, 0);!g' \
    /usr/share/plymouth/themes/ubuntu-logo/ubuntu-logo.script
sudo sed -i -E 's!^Window.SetBackgroundBottomColor.*$!Window.SetBackgroundBottomColor (0, 0, 0);!g' \
    /usr/share/plymouth/themes/ubuntu-logo/ubuntu-logo.script
sudo update-initramfs -u

# Fix color on lock screen
sudo perl -i -p0 -e 's/(#lockDialogGroup[^}]*\bbackground:\s*)\S+(.*?;)/\1#2c2c2c\2/smg' /usr/share/gnome-shell/theme/ubuntu.css

# Fix color of grub boot background
sudo sed -E -i 's!(^if background_color).*(; then$)!\1 0,0,0\2!g' /usr/share/plymouth/themes/default.grub
sudo update-grub

# config to run docker without root
sudo gpasswd -a graham docker

# disable Nautilus (file explorer) fancy but useless search. This almost makes
# it feel like typeahead exists.
gsettings set org.gnome.nautilus.preferences fts-default false
gsettings set org.gnome.nautilus.preferences recursive-search 'never'

