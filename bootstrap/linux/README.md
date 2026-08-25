# Ubuntu Linux Computer Setup

Mainly focused on a computer used for development.

## Quick start

```sh
./ubuntu.sh
# If using Ubuntu
./ubuntu-desktop.sh
# OR if using Linux Mint
./mint-desktop.sh
```

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

To remap Caps Lock to F13 (used for the global terminal shortcut), use [`keyd`](https://github.com/rvaiya/keyd). It remaps at the kernel input level, so a single config works under both X11 and Wayland sessions and, unlike editing files under `/usr/share/X11/xkb/`, it isn't reverted when `xkb-data`/`xkeyboard-config` gets updated.

```sh
# Ubuntu 25.04+ / Debian 13+ have keyd available. On older releases, add the PPA first:
sudo add-apt-repository ppa:keyd-team/ppa
sudo apt update

sudo apt install keyd
sudo systemctl enable --now keyd
```

Create `/etc/keyd/default.conf`:

```ini
# apply to every keyboard device (use specific vendor:product ids to target one keyboard)
[ids]
*

[main]
capslock = f13
```

Reload with `sudo keyd.rvaiya reload` (or reboot).

_Note_: the `ppa:keyd-team/ppa` package installs the binary as `keyd.rvaiya` rather than `keyd` (to avoid clashing with an unrelated package of that name), though the systemd service is still called `keyd.service`.

## Nerd Fonts

`ubuntu-desktop.sh` and `mint-desktop.sh` each install a Nerd Font at the end of the run - the patched version of that distro's own default monospace font (`UbuntuMono` on Ubuntu, `DejaVuSansMono` on Mint), so no manual step is needed.

To install another one, run the script directly:

```sh
./bootstrap/linux/nerd-font.sh FiraCode
```

The name must match a release asset basename from https://github.com/ryanoasis/nerd-fonts/releases (e.g. `FiraCode`, `Hack`, `JetBrainsMono`), not the display name shown on nerdfonts.com. Defaults to `UbuntuMono` if no argument is given.

On GNOME you can verify the current system monospace font with:

```sh
gsettings get org.gnome.desktop.interface monospace-font-name
```

Cinnamon has no equivalent gsettings key - check System Settings > Fonts instead.

You'll need to restart the terminal for the font to take effect.

## VPN

- Download and install [PIA VPN](https://www.privateinternetaccess.com/)
- Create desktop shortcut in ~/.config/autostart folder

## scrolling speed

...
