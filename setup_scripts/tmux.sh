#!/usr/bin/env bash
git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack --depth=1 2>/dev/null || \
    (cd ~/.tmux-themepack && git pull)


