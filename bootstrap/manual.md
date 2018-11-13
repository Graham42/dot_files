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
