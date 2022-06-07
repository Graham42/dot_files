# Manual setup steps

## Prompt

Note: prerequisite: install a [Nerd Font](https://www.nerdfonts.com/)

## Git Merge tool

Install
[p4merge](https://www.perforce.com/products/helix-core-apps/merge-diff-tool-p4merge)

### Windows

```powershell
winget install Perforce.P4Merge
```

### Ubuntu

See if the commented block in the [ubuntu-desktop.sh](./ubuntu-desktop.sh)
script will work

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
winget install BraveSoftware.BraveBrowser
winget install Google.Chrome
# we need interactive mode to select options to add VSCode to the PATH to launch from WSL
# also need scope to be machine so that we're not trying to install as admin
winget install Microsoft.VisualStudioCode --interactive --scope machine
winget install Microsoft.WindowsTerminal
# version 0.58.0 is broken: https://github.com/microsoft/PowerToys/issues/18015
winget install Microsoft.PowerToys --version 0.57.2
# X Server, required for windows 10 (11 unconfirmed) to make vim work with system clipboard
# See https://superuser.com/a/1345241
winget install marha.VcXsrv
# VPN
winget install PrivateInternetAccess.PrivateInternetAccess
```

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

1.  Install deps

    ```sh
    sudo apt install xdg-utils -y
    ```

1.  Generate a key

    ```sh
    ssh-keygen -t rsa -b 4096
    ```

1.  Add it to github

    ```sh
    cat ~/.ssh/id_rsa.pub
    xdg-open https://github.com/settings/ssh/new
    ```

1.  Verify access
    ```sh
    ssh -T git@github.com
    ```

### Automated setup

Clone [dot_files repo](https://github.com/Graham42/dot_files) and run setup

_TODO fix dotfiles_

### Fonts

Download UbuntuMono Nerd Font from https://www.nerdfonts.com/font-downloads

### Windows terminal config

- Theme for Ubuntu:
  https://github.com/edurojasr/Windows-Terminal-Theme-Night-Owl
- no bell
- launch with F13 _TODO how_
- default start maximized, on login, with Ubuntu

To get path to settings.json in WSL

```sh
wt_settings=$(powershell.exe '(Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*\LocalState" -Filter settings.json -Recurse).FullName')
wslpath -a $wt_settings
```

- _TODO save config json as code in this repo_

### TODO these steps: misc

- setup windows vscode settings as code linked to dot files
- make sure clipboard works back and forth, including vim, tmux
  - follow steps at
    https://superuser.com/questions/1291425/windows-subsystem-linux-make-vim-use-the-clipboard/1345241#1345241
    Make sure to disable access control in the VcXsrv config
  - https://nickymeuleman.netlify.app/blog/gui-on-wsl2-cypress

### Non-dev programs

```powershell
# Spotify replacement
winget install TIDALMusicAS.TIDAL
```

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
