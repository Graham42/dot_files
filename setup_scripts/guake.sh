#!/usr/bin/env bash
# see https://github.com/Guake/guake/issues/292#issuecomment-408930278

SETTINGS_BACKUP="${HOME}/dot_files/guake_settings_backup"

if [ -e "$SETTINGS_BACKUP" ]; then
  dconf reset -f /apps/guake/
  dconf load /apps/guake/ < "$SETTINGS_BACKUP"
else
  dconf dump /apps/guake/ > "$SETTINGS_BACKUP"
fi

if [ -e "/usr/share/applications/guake.desktop" ]; then
  mkdir -p $HOME/.config/autostart/
  ln -sf /usr/share/applications/guake.desktop $HOME/.config/autostart/guake.desktop
else
  echo "guake desktop file not found. Maybe guake isn't installed yet?"
  exit 1
fi
