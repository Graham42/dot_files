#!/bin/bash

mkdir -p ~/.vim/tmp
mkdir -p ~/.vim/undo
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
vim +PluginInstall +qall

