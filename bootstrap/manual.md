# Dropbox

- Download and install from https://www.dropbox.com/install-linux
- Create desktop shortcut in ~/.config/autostart folder

# VPN

- Download and install PIA VPN
- Create desktop shortcut in ~/.config/autostart folder

# Do not disturb extension

```sh
gnome-shell --version
sudo apt-get install chrome-gnome-shell
```

Open in Firefox:
https://extensions.gnome.org/extension/964/do-not-disturb-button/ Install. Open
gnome-tweak settings, disable notification count.

# put windows extension

....

# Bash

If on ubuntu, there's a bunch of default cruft in `~/.bashrc` make sure to
comment out `HISTSIZE` and `HISTFILESIZE` so it doesn't mess with settings.

# Sleep

some older hardware doesn't sleep well

```sh
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing"
```

go into gnome tweak > power > disable sleep on lid close

# Prompt

Note: prerequisite: install a [Nerd Font](https://www.nerdfonts.com/)

```sh
curl -sS https://starship.rs/install.sh | sh
```
