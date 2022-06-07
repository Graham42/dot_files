#!/usr/bin/env bash

# Download random background / lockscreen wallpapers
# For GNOME desktop. Tested on Ubuntu 18.04

set -exo pipefail

WALLPAPER_FOLDER="$HOME/Pictures/Wallpapers"
mkdir -p "$WALLPAPER_FOLDER"

# Change these to match your screen resolution
WIDTH=2560
HEIGHT=1440

downloadRandomImage() {
    # Download a random image for this resolution
    FILENAME=$(cd "$WALLPAPER_FOLDER" &&
        curl --remote-header-name --location --remote-name \
            --silent --write-out "%{filename_effective}" \
            "https://picsum.photos/$WIDTH/$HEIGHT?")
    # Return the path of the downloaded file
    echo "$WALLPAPER_FOLDER/$FILENAME"
}

DESKTOP_IMAGE=$(downloadRandomImage)
gsettings set org.gnome.desktop.background picture-uri "file://$DESKTOP_IMAGE"

LOCKSCREEN_IMAGE=$(downloadRandomImage)
gsettings set org.gnome.desktop.screensaver picture-uri "file://$LOCKSCREEN_IMAGE"
