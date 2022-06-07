#!/usr/bin/env bash

# If we're running in WSL, we're going to be using Windows Terminal, not Hyper
if grep -i -q microsoft /proc/version; then
  exit 0;
fi

if [ -e "/usr/share/applications/hyper.desktop" ]; then
  mkdir -p "$HOME/.config/autostart/"
  ln -sf /usr/share/applications/hyper.desktop "$HOME/.config/autostart/hyper.desktop"
else
  echo "hyper desktop file not found. Maybe hyper isn't installed yet?"
  exit 1
fi

