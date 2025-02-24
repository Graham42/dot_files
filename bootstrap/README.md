# Manual setup steps

## Prompt

https://starship.rs/

Note: prerequisite: install a [Nerd Font](https://www.nerdfonts.com/)

## Git Merge tool

VSCode now has a 3 way merge, so use that

---

## Windows

For inspiration see https://docs.microsoft.com/en-us/windows/dev-environment/

### Update windows

1. Configure "get updates for other microsoft software"
1. Windows updates, restart, repeat until no updates
1. Uninstall any Windows bloatware

### Install programs

These are installed using the
[windows package manager](https://docs.microsoft.com/en-us/learn/modules/explore-windows-package-manager-tool/)

```powershell
winget install Google.Chrome
# we need interactive mode to select options to add VSCode to the PATH to launch from WSL
# also need scope to be machine so that we're not trying to install as admin
winget install Microsoft.VisualStudioCode --interactive --scope machine
winget install Microsoft.WindowsTerminal
winget install Microsoft.PowerToys
# VPN
winget install PrivateInternetAccess.PrivateInternetAccess
# Command prompt
winget install --id Starship.Starship
```

- [Obsidian](https://obsidian.md/download)

#### Docker

Before installing Docker desktop, make sure you have saved all your work, as
you'll need to log out and back in for Docker to work.

```powershell
# Make sure to pick the WSL backend
winget install Docker.DockerDesktop --interactive
```

### [PowerToys](https://github.com/microsoft/PowerToys) config

- Remap CapsLock to F13

### WSL setup

1.  Open Admin PowerShell and run

    ```powershell
    wsl --install
    ```

1.  A restart will likely be required
1.  Run `wsl` and follow the prompts to create a user
1.  Update all existing programs

    ```sh
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove
    ```

### GitHub ssh key setup

In a WSL terminal window

1.  Follow [Generate an ssh key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=linux#generating-a-new-ssh-key)

    ```sh
    ssh-keygen -t ed25519 -C "graham.mcgregor04+github@gmail.com"
    # ...
    ```

1.  Add it to github (https://github.com/settings/ssh/new)

    ```sh
    cat ~/.ssh/id_ed25519.pub
    ```

1.  Verify access
    ```sh
    ssh -T git@github.com
    ```

### Automated setup

Clone [dot_files repo](https://github.com/Graham42/dot_files) and run setup

_TODO fix dotfiles_

### Fonts

Download UbuntuSans Nerd Font from https://www.nerdfonts.com/font-downloads

### Windows terminal config

- Theme for Ubuntu:
  https://github.com/edurojasr/Windows-Terminal-Theme-Night-Owl
- no bell
- launch with F13
    - Remap key with [PowerToys Keyboard Manager utility for Windows](https://learn.microsoft.com/en-us/windows/powertoys/keyboard-manager)
    - Set `globalSummon` config: https://learn.microsoft.com/en-us/windows/terminal/customize-settings/actions#global-summon
- default start maximized, on login, with Ubuntu
- Remove action/command Paste with shortcut <kbd>Ctrl+V</kbd> from settings. Otherwise this will interfere with vim visual mode.

- _TODO save config json as code in this repo_

### TODO these steps: misc

- setup windows vscode settings as code linked to dot files
- make sure clipboard works back and forth, including vim, tmux
  - may just need `sudo apt-get install vim-gtk3`
  - follow steps at
    https://superuser.com/questions/1291425/windows-subsystem-linux-make-vim-use-the-clipboard/1345241#1345241
    Make sure to disable access control in the VcXsrv config
  - https://nickymeuleman.netlify.app/blog/gui-on-wsl2-cypress

### Non-dev programs

```powershell
winget install Zoom.Zoom
winget install SlackTechnologies.Slack
```

#### Zoom

- Under Audio:
  - "Automatically join audio by computer when joining a meeting"
  - "Always mute microphone when joining meeting"
  - Uncheck "Press and hold SPACE key to temporarily unmute yourself"
- Under Video:
  - "Always show video preview dialog when joining a video meeting"
- Under General:
  - "Stop my video and audio when my device is locked"

---

## Linux

### VPN

- Download and install [PIA VPN](https://www.privateinternetaccess.com/)
- Create desktop shortcut in ~/.config/autostart folder

### Gnome shell extensions

```sh
gnome-shell --version
sudo apt-get install chrome-gnome-shell
```

- [Do not disturb extension](https://extensions.gnome.org/extension/964/do-not-disturb-button/)
  - After install, open gnome-tweak settings, disable notification count
- [Put windows extension](https://extensions.gnome.org/extension/39/put-windows/)

### Bash

If on ubuntu, there's a bunch of default cruft in `~/.bashrc` make sure to
comment out `HISTSIZE` and `HISTFILESIZE` so it doesn't mess with settings.

### Docker

- Consider
  [running the Docker daemon as a non-root user (Rootless mode)](https://docs.docker.com/engine/security/rootless/)
- At least allow the user to run docker without root. See
  [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)
- Install Docker to be compatible with WSL if applicable _TODO how?_

### Remap keys

Want to remap caps lock to F13 to use for global terminal:
http://www.fascinatingcaptain.com/blog/remap-keyboard-keys-for-ubuntu/

```sh
sudo -e /usr/share/X11/xkb/symbols/pc
```

Update the key definition for caps lock

```diff
- key <CAPS> { [ Caps_Lock ] };
+ key <CAPS> { [ F13       ] };
```

Then clear any cached stuff in `/var/lib/xkb/` and reboot
