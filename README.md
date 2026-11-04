# Automated Config Setup

This repo sets up a machine for software dev with my preferences.

Setup steps:

```sh
git clone https://github.com/Graham42/dot_files.git ~/dot_files
cd ~/dot_files && ./init_all.sh
```

# Structure

- Anything in `home/` is linked to the user's home directory (`~`)
- Running `init_all.sh` will create/update a marked section in `~/.bashrc` with
  the contents of `bashrc_body.sh`.
- Any scripts in `setup_scripts/` will be run as part of `init_all.sh`
- Scripts in `bootstrap/` are for initial machine setup. See the
  [bootstrap README](./bootstrap/README.md) for additional manual instructions

# tmux

- Press `Ctrl+a`, then `Ctrl+t` to search windows across all sessions, excluding
  only the current window in the session you opened the picker from. Other
  sessions' active windows remain included. Results use one global order: most
  recently accessed first, at the top, even while searching. Background output
  does not change the order. Select a result to switch to that window and session.
- Press `Ctrl+a`, then lowercase `l` to return to the most recently visited other
  window, even in another session. Repeat to toggle back. Linked copies of the
  current window are skipped. If no other window has a recorded visit, it does
  nothing.
- Access tracking starts when the tmux config is loaded and lasts until the tmux
  server exits. Windows not visited since tracking started appear after visited
  windows; earlier access history cannot be recovered.
