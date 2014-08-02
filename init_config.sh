#!/bin/bash
# This script is to speed up setting up a new VM with my personal config

# config variables
BASHRC_EXTEND=".bashrc_extend"
CONFIG_FILES=( \
	"$BASHRC_EXTEND" \
	".git-completion.bash" \
	".git-prompt.sh" \
	".colors.sh" \
	".gitconfig" \
	".vimrc" \
)

dir=$(pwd)

function error {
	echo "Error occured: "$1
	exit 1
}

# check if this script has been run before
if $(grep "$BASHRC_EXTEND" ~/.bashrc -q); then
	error "Already initialized."
fi

# first check that we're not going to overwrite files
for file in ${CONFIG_FILES[*]}; do
	if [ ! -f $file ]; then
		error "The file $file was not found in the current directory."
	fi
	if [ -f ~/$file ]; then
		error "The file ~/$file already exists."
	fi
done

# symbolic link needed files
for file in ${CONFIG_FILES[*]}; do
	ln -s $dir/$file ~/$file
done

# add import to ~/.bashrc
bashrc_import="
if [ -f ~/.bashrc_extend ]; then
	. ~/.bashrc_extend
fi
"
echo "$bashrc_import" >> ~/.bashrc

# run everything!
. ~/.bashrc

echo "Initialization complete!"

