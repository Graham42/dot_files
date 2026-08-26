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

## Scrolling speed

Touchpad scroll speed is the one touchpad setting that neither GNOME nor Cinnamon puts in their settings app. Run this instead:

```sh
./scroll-speed.sh              # defaults to --factor 0.25, lower is slower
./scroll-speed.sh --uninstall
```

The script checks what kind of session you are in and picks a method to match, because there is no single answer:

- **Wayland**, which is all Ubuntu 26.04 has. GNOME 50 dropped the X11 session, so there is no `/usr/share/xsessions` at all. The script installs [Wayland Scroll Factor](https://github.com/daniel-g-carrasco/wayland-scroll-factor), runs `wsf set` and `wsf enable`, then asks you to restart.
- **X11**, which is still Mint 22's default. The script writes a small `xorg.conf.d` file that sets the libinput driver's `ScrollPixelDistance`. Nothing to install, and it takes effect right away.

