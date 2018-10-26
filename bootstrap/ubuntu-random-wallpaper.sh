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
    # pick a random image from the ones available for this resolution
    IMAGE_ID=$(curl -Ls -w "%{url_effective}" -o /dev/null "https://picsum.photos/$WIDTH/$HEIGHT/?random" | grep -o "[0-9]\+$")
    # Download the chosen image
    curl -JL -o "$WALLPAPER_FOLDER/image-$IMAGE_ID.jpeg" "https://picsum.photos/g/$WIDTH/$HEIGHT?image=$IMAGE_ID"
    # Return the path of the downloaded file
    echo "$WALLPAPER_FOLDER/image-$IMAGE_ID.jpeg"
}

DESKTOP_IMAGE=$(downloadRandomImage)
gsettings set org.gnome.desktop.background picture-uri "file://$DESKTOP_IMAGE"

LOCKSCREEN_IMAGE=$(downloadRandomImage)
gsettings set org.gnome.desktop.screensaver picture-uri "file://$LOCKSCREEN_IMAGE"
