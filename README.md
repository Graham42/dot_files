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
