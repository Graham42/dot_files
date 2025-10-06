# Ubuntu Linux Computer Setup

Mainly focused on a computer used for development.

## Prompt

Install Starship from https://starship.rs/

Note: prerequisite: install a [Nerd Font](https://www.nerdfonts.com/)

### VPN

- Download and install [PIA VPN](https://www.privateinternetaccess.com/)
- Create desktop shortcut in ~/.config/autostart folder

### Remap keys

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
