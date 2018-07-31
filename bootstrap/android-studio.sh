#!/usr/bin/env bash

# Android dev moves quick-ish, check instructions at:
# https://developer.android.com/studio/install#linux

set -eo pipefail

sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386

echo "Download from https://developer.android.com/studio/"
echo ""
echo "Then follow the instructions at https://developer.android.com/studio/install#linux"
echo ""
echo "To generate a .desktop file entry: Launch Android Studio, open Tools > Create Desktop Entry"
