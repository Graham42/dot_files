#!/bin/bash

mkdir -p ~/.vim/tmp
mkdir -p ~/.vim/undo
if [ ! -f ~/.vim/autoload/plug.vim ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim +PlugUpdate +qall

