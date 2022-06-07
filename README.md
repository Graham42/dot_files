# Automated Config Setup

This repo sets up a machine for software dev with my preferences.

Setup steps:

```sh
git clone https://github.com/Graham42/dot_files.git ~/dot_files
cd ~/dot_files && ./init_all.sh
```

# Structure

- Anything in `home/` is linked to the user's home directory and then the
  directory structure inside is followed
- Running `init_all.sh` will create or update a marked section in `~/.bashrc`
  with the contents of `bashrc_body.sh`.
- Any scripts in `setup_scripts` will be run as part of `init_all.sh`
