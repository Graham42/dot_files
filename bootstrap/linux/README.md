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

- **Alacritty drop-down terminal**: a Guake-style terminal on a global hotkey. Caps Lock opens it (see [Remap keys](#remap-keys)). `ubuntu-desktop.sh` runs `alacritty-quake.py`, so there is no manual step. Run it directly to change the hotkey or undo the setup:

  ```sh
  ./alacritty-quake.py --shortcut '<Super>grave'
  ./alacritty-quake.py --uninstall
  ```

  Ubuntu only - a GNOME Shell extension drives it, and Cinnamon has no equivalent. The script's header explains why it's built that way, and why it is the one python script in this directory. It needs no packages beyond python3 itself.

- **Terminal color theme**: the same script installs one, so there is no manual step here either. It takes a theme from [Gogh](https://github.com/Gogh-Co/Gogh), converts it to Alacritty's TOML in `~/.config/alacritty/themes/`, and adds an import for it to `~/.config/alacritty/alacritty.toml`. Both the drop-down and ordinary Alacritty windows pick it up. Defaults to Night Owl; to use another:

  ```sh
  ./alacritty-quake.py --theme 'Tokyo Night'
  ./alacritty-quake.py --theme ''            # leave the colors alone
  ```

  The name is the theme's file name in [Gogh's themes directory](https://github.com/Gogh-Co/Gogh/tree/master/themes), minus the `.yml`. Only the import line in `alacritty.toml` is managed - the rest of that file is yours, and switching themes replaces the old import rather than stacking on it.

## Desktop Customization

- **Gnome Tweaks**: For font customization. If system is using Gnome.

  ```sh
  sudo apt install gnome-tweaks
  ```

- **Display Settings**:
  - Enable Night Light

## Remap keys

Caps Lock is remapped to F14, the key the drop-down terminal opens with. Both `ubuntu-desktop.sh` and `mint-desktop.sh` run `remap-keys.sh`, so there is no manual step. Mint has no drop-down terminal yet, so there Caps Lock just sends a key nothing is bound to.

To change the mapping, or undo it, run the script directly:

```sh
./remap-keys.sh                             # capslock -> f14
./remap-keys.sh --from capslock --to esc    # or anything in `keyd.rvaiya list-keys`
./remap-keys.sh --uninstall
```

Two things to know before binding a shortcut to it:

- The desktop sees F14 as `XF86Launch5`. xkb renames F13 through F18, so a shortcut set to `F14` never fires.
- If a bad config leaves the keyboard unusable, press backspace, escape and enter together. That is keyd's panic sequence, and it kills the daemon.

The script's header covers the rest: why [`keyd`](https://github.com/rvaiya/keyd) rather than the desktop's own keyboard settings, why F14 and not F13, and where the package comes from on each distro.

## Nerd Fonts

`ubuntu-desktop.sh` and `mint-desktop.sh` each install a Nerd Font at the end of the run - the patched version of that distro's own default monospace font (`UbuntuMono` on Ubuntu, `DejaVuSansMono` on Mint), so no manual step is needed.

To install another one, run the script directly:

```sh
./nerd-font.sh FiraCode
```

The name must match a release asset basename from https://github.com/ryanoasis/nerd-fonts/releases (e.g. `FiraCode`, `Hack`, `JetBrainsMono`), not the display name shown on nerdfonts.com. Defaults to `UbuntuMono` if no argument is given.

On GNOME you can verify the current system monospace font with:

```sh
gsettings get org.gnome.desktop.interface monospace-font-name
```

Cinnamon has no equivalent gsettings key - check System Settings > Fonts instead.

You'll need to restart the terminal for the font to take effect.

## VPN

`ubuntu-desktop.sh` and `mint-desktop.sh` both install the [PIA](https://www.privateinternetaccess.com/) app, so there is no manual step. Run it directly to install on its own, or to remove the app:

```sh
./pia-vpn.sh
./pia-vpn.sh --uninstall
```

PIA has no apt repo - only a `.run` installer whose filename carries the version - so the script looks up the current release, skips a machine that already has it, and upgrades one that doesn't. Settings survive an upgrade.

Two things are left to do by hand after it runs:

- Log in. Your PIA username looks like `p1234567`.
- Turn on **Launch on System Startup** in the app's settings if you want it running at login. The client writes `~/.config/autostart/piavpn.desktop` from that setting and rewrites it on launch, so it is not worth scripting.

## Scrolling speed

Touchpad scroll speed is the one touchpad setting that neither GNOME nor Cinnamon puts in their settings app. Run this instead:

```sh
./scroll-speed.sh              # defaults to --factor 0.25, lower is slower
./scroll-speed.sh --uninstall
```

The script checks what kind of session you are in and picks a method to match, because there is no single answer:

- **Wayland**, which is all Ubuntu 26.04 has. GNOME 50 dropped the X11 session, so there is no `/usr/share/xsessions` at all. The script installs [Wayland Scroll Factor](https://github.com/daniel-g-carrasco/wayland-scroll-factor), runs `wsf set` and `wsf enable`, then asks you to restart.
- **X11**, which is still Mint 22's default. The script writes a small `xorg.conf.d` file that sets the libinput driver's `ScrollPixelDistance`. Nothing to install, and it takes effect right away.

