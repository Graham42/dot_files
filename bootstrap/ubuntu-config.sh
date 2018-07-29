#!/usr/bin/env bash

set -ex
set -o pipefail

# need to update index for locate command
sudo updatedb
# set chrome at default browser
CHROME_DESKTOP=$(locate -r google.*chrome.*\.desktop | head -n1 | xargs basename)
xdg-settings set default-web-browser "$CHROME_DESKTOP"

# make Alt + Tab switch windows instead of applications
# Source: https://people.gnome.org/~federico/blog/alt-tab.html
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab', '<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward  "['<Alt><Shift>Tab', '<Super><Shift>Tab']"

# Hide desktop icons
gsettings set org.gnome.desktop.background show-desktop-icons false

# Autostart tilda
TILDA_DESKTOP=$(locate tilda.desktop)
mkdir -p ~/.config/autostart/
(cd ~/.config/autostart/ && ln -sf "$TILDA_DESKTOP")

# Configure tilda to use our config
TILDA_CONFIG="$HOME/dot_files/home/_.config/tilda/config_0"
sudo sed -i -E "s,(Exec=.*),\1 -g '$TILDA_CONFIG',g" "$TILDA_DESKTOP"

# TODO
# - change purple color for boot up screen
# - change purple background for terminal
# - set background for desktop & login screen
