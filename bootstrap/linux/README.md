# Ubuntu Linux Computer Setup

Mainly focused on a computer used for development.

## Initial Package Installation

```sh
sudo apt update && sudo apt upgrade -y
sudo apt install git vim-gtk3 jq tmux tree xclip curl ripgrep
sudo apt autoremove
```

## Development Tools

- **VS Code**: Install from https://code.visualstudio.com/
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

- **Gnome Tweaks**: For font customization. If system is using Gnome.
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

```sh
./bootstrap/linux/nerd-font.sh UbuntuMono
```

Pass a different font name to install another one - it must match a release asset basename from https://github.com/ryanoasis/nerd-fonts/releases (e.g. `FiraCode`, `Hack`, `JetBrainsMono`), not the display name shown on nerdfonts.com. Defaults to `UbuntuMono` if no argument is given.

You'll need to restart the terminal for the font to take effect.

## VPN

- Download and install [PIA VPN](https://www.privateinternetaccess.com/)
- Create desktop shortcut in ~/.config/autostart folder


## scrolling speed

...
