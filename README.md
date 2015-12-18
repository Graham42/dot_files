# My Automated Config Setup

I wanted an automated way to quickly setup a shell with my own customizations.  Setup is at ~3
commands right now.

Setup steps:

```sh
git clone https://github.com/Graham42/dot_files.git ~/dot_files
~/dot_files/init_all.sh
source ~/.bashrc
```

# Structure

- Anything in `home/` is linked to the user's home directory and then the directory structure
  inside is followed
- All dot files in `home/` are escaped with a leading underscore so it's not as easy to forget
  about files that are hidden. Symbolic links are created with the leading underscore's removed.
  Example: `_.vimrc` becomes `.vimrc`
- Running `init_all.sh` will create and update a marked section in `~/.bashrc`.
  - `bashrc_body.sh` is the main block content.
  - If there are files in the `os_specific_bashrc/` folder, they will be included if the OS check
    passes.  OS specific files require a 2 line header, where the second line is a commented shell
    command that will return a zero exit status if it detects the correct OS.

    Example:

    ```sh
    # OS check:
    # cat /etc/*-release | grep '^NAME=\"Arch Linux\"' -q
    ```
- Any scripts in `setup_scripts` will be run, but they must be executable or the setup will fail.
