#!/usr/bin/env bash

set -ex
set -o pipefail

mkdir -p ~/Pictures/Wallpapers

# Download random background / lockscreen wallpapers

RANDOM_NAME=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
curl -JL -o "$HOME/Pictures/Wallpapers/${RANDOM_NAME}.jpeg" https://picsum.photos/g/2560/1440?random
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/${RANDOM_NAME}.jpeg"

RANDOM_NAME=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
curl -JL -o "$HOME/Pictures/Wallpapers/${RANDOM_NAME}.jpeg" https://picsum.photos/g/2560/1440?random
gsettings set org.gnome.desktop.screensaver picture-uri "file://$HOME/Pictures/Wallpapers/${RANDOM_NAME}.jpeg"
