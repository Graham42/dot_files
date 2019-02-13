# Dropbox

- Download and install from https://www.dropbox.com/install-linux
- Create desktop shortcut in ~/.config/autostart folder

# VPN

- Download and install PIA VPN
- Create desktop shortcut in ~/.config/autostart folder

# Increase inotify watches

See: https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers

```sh
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```


# Do not disturb extension

```sh
gnome-shell --version
sudo apt-get install chrome-gnome-shell
```

Open in Firefox: https://extensions.gnome.org/extension/964/do-not-disturb-button/
Install.
Open gnome-tweak settings, disable notification count.

# put windows extension
....


# Bash

If on ubuntu, there's a bunch of default cruft in `~/.bashrc` make sure to
comment out `HISTSIZE` so it doesn't mess with settings.


# Sleep

some older hardware doesn't sleep well

```sh
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing"
```

go into gnome tweak > power > disable sleep on lid close

