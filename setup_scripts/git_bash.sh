#!/usr/bin/env bash
git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt \
    --depth=1 2>/dev/null || \
    (cd ~/.bash-git-prompt && git pull)
