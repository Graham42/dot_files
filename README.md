# My Automated Config Setup

I wanted an automated way to quickly setup a shell with my own customizations.  Setup is at ~4
commands right now, except for my vim config which I just need to automate the plugin downloading
and pathogen setup. (Planning on that soon!)

Setup steps:

```sh
git clone https://github.com/Graham42/dot_files.git
cd dot_files
./init_all.sh
source ~/.bashrc
```

# Structure

- All dot files are escaped in this repo with a leading `_`. Symbolic links are created with the
  leading `_`'s removed. Example: `_.vimrc` becomes `.vimrc`
- Anything in `home/` is linked to `~` and then the directory structure inside is followed
- Running `init_all.sh` will create and update a marked section in `~/.bashrc`.
  - `include_common.sh` is the main block content.
  - If there are files in the `os_specific/` folder, they will be included if the OS check passes.
    OS specific files require a 2 line header, where the second line is a commented shell command
    that will return a 0 exit status if it detects the correct OS.

    Example:

    ```sh
    # OS check:
    # cat /etc/*-release | grep '^NAME=\"Arch Linux\"' -q
    ```

