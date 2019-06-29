# My Automated Config Setup

I wanted an automated way to quickly setup a shell with my own customizations.

Setup steps:

```sh
git clone https://github.com/Graham42/dot_files.git ~/dot_files
~/dot_files/init_all.sh
source ~/.bashrc
do_update
```

# Structure

- Anything in `home/` is linked to the user's home directory and then the
  directory structure inside is followed
- Running `init_all.sh` will create and update a marked section in `~/.bashrc`.

  - `bashrc_body.sh` is the main block content.
  - If there are files in the `os_specific_bashrc/` folder, they will be
    included if the OS check passes. OS specific files require a 2 line header,
    where the second line is a commented shell command that will return a zero
    exit status if it detects the correct OS.

    Example:

    ```sh
    # OS check:
    # cat /etc/*-release | grep '^NAME=\"Arch Linux\"' -q
    ```

- Any scripts in `setup_scripts` will be run, but they must be executable or the
  setup will fail.

# How To

## Remap keys

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

# License

MIT License

Copyright (c) 2016 Graham McGregor

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
