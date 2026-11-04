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

- Press `Ctrl+a`, then `Ctrl+t` to search all windows across all sessions,
  including each session's active window. Results are ordered by most recent
  activity. Select a result to switch to that window and session.
