# My Automated Config Setup
I wanted an automated way to quickly setup a shell with my own customizations.
Setup is at ~4 commands right now, except for my vim config which I just need to
automate the plugin downloading and pathogen setup. (Coming soon!)

Ready, set, go!
```sh
git clone https://github.com/Graham42/dot_files.git
cd dot_files
./init_all.sh
source ~/.bashrc
```

# Structure
* All dot files are escaped in this repo with a leading `_`. Symbolic links are
created to targets with the `_`'s removed.
* Anything in `home` is linked to `~` and then the directory structure inside is
followed
* Running `init_all.sh` will create and update a marked block in `~/.bashrc`.
  * `include_common.sh` is the main block content.
  * If there are file in the `os_specific` folder, they may be included. OS
  specific files require a 2 line header where the second line is a commented
  command that would return a 0 exit status if it detected the correct OS.
  ```sh
  # OS check example:
  # cat /etc/*-release | grep '^NAME=\"Arch Linux\"' -q
  ```

