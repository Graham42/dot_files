# Ubuntu Linux Computer Setup

Mainly focused on a computer used for development.

## Initial Package Installation

```sh
sudo apt update && sudo apt upgrade -y
sudo apt install git vim-gtk3 jq tmux tree xclip curl
sudo apt autoremove
```

## Development Tools

- **VS Code**: Install from https://code.visualstudio.com/
- **Cursor**: Install from https://cursor.sh/
  - Configure privacy settings first
  - Enable Tab completion in markdown files
- **1Password**: Install from https://1password.com/
  - Set up global keyboard shortcut: https://support.1password.com/keyboard-shortcuts/?linux
  - Note: Ubuntu LTS uses Wayland

## Terminal Setup

- **Guake**: Dropdown terminal
  ```sh
  sudo apt install guake
  ```
  - Configure global keyboard shortcut in Ubuntu system settings (Wayland requirement)

- **Terminal Color Theme**: Install using [Gogh](https://github.com/Gogh-Co/Gogh)

- **Starship Prompt**: Install from https://starship.rs/
  - Prerequisite: install a [Nerd Font](https://www.nerdfonts.com/)

## Desktop Customization

- **Gnome Tweaks**: For font customization
  ```sh
  sudo apt install gnome-tweaks
  ```

- **Display Settings**:
  - Enable Night Light

## Remap keys

To remap Caps Lock to F13 to use for global terminal (source
http://www.fascinatingcaptain.com/blog/remap-keyboard-keys-for-ubuntu/)

```sh
EDITOR=vim sudo -e /usr/share/X11/xkb/symbols/pc
```

Update the key definition for caps lock:

```diff
- key <CAPS> { [ Caps_Lock ] };
+ key <CAPS> { [ F13       ] };
```

- Reboot the computer
- If settings don't persist clear any cached files in `/var/lib/xkb/` and reboot

## Automated setup scripts

Run

```sh
cd ~/dot_files && ./init_all.sh
```

## Nerd Fonts

You can verify the system font with:

```sh
gsettings get org.gnome.desktop.interface monospace-font-name
```

- Download UbuntuSans Nerd Font from https://www.nerdfonts.com/font-downloads
- Install the font

```sh
# unzip the font
unzip ~/Downloads/UbuntuSans.zip -d /tmp/UbuntuSans
# copy the font to the system fonts directory
cp /tmp/UbuntuSans/*.ttf /usr/local/share/fonts/
# clear the font cache
fc-cache -f -v
```

You'll need to restart the terminal for the font to take effect.

## VPN

- Download and install [PIA VPN](https://www.privateinternetaccess.com/)
- Create desktop shortcut in ~/.config/autostart folder
