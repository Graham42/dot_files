#!/usr/bin/env bash
# This script is to speed up setting up a new machine with my personal config

set -eo pipefail

THIS_SCRIPT="init_all.sh"

################################################################################
## Util functions for this script

# Colors for nicer output
Color_Off="\033[0m"         # Text Reset
Red="\033[0;31m"            # Red
Green="\033[0;32m"          # Green
Yellow="\033[0;33m"         # Yellow
Cyan="\033[0;36m"           # Cyan

function ls_dirs {
    ls_type d "$@"
}
function ls_files {
    ls_type f "$@"
}
function ls_type {
    if [ "${2}x" == "x" ]; then
        DIR=\.
    else
        DIR="$2"
    fi
    find "$DIR" -mindepth 1 -maxdepth 1 -type "$1" | sed "s#^${DIR}/##g"
}
function logok {
    echo -e "${Green}$*$Color_Off"
}
function loginfo {
    echo -e "${Cyan}$*$Color_Off"
}
function logwarn {
    echo -e "${Yellow}$*$Color_Off"
}
function logfatal {
    echo -e "${Red}$*$Color_Off"
    exit 1
}

################################################################################
## Setup

# This script should be the master, should be run, not sourced
if [ $THIS_SCRIPT != "$(basename "$0")" ]; then
    logfatal "This script should be run, not sourced"
fi

# allow this script to be run from anywhere
cd "$(dirname "$0")"

loginfo "Updating config for user: $USER"

################################################################################
## Create/update a block in ~/.bashrc with our modifications

BASH_RC_BODY_FILE="bashrc_body.sh"

# WARNING: if header/footer are changed, will mess up auto-update
BASHRC_HEADER="####################_BEGIN_DOT_FILES_AUTOBLOCK_######################"
BASHRC_FOOTER="#####################_END_DOT_FILES_AUTOBLOCK_#######################"

if [ ! -e $BASH_RC_BODY_FILE ]; then
    logfatal "Missing file '$BASH_RC_BODY_FILE'"
fi
bashrc_body=$( cat $BASH_RC_BODY_FILE )
echo "Updating block in ~/.bashrc"
# auto update the block in ~/.bashrc
if grep "$BASHRC_HEADER" ~/.bashrc -q; then
    escaped_body=$(echo "$bashrc_body" | sed -e':a' -e'N' -e'$!ba' -e's/\n/\\n/g')
    sed -i'' -e"/^$BASHRC_HEADER$/,/^$BASHRC_FOOTER$/c $BASHRC_HEADER\n$escaped_body\n$BASHRC_FOOTER" ~/.bashrc
else
    echo -e "\n$BASHRC_HEADER\n$bashrc_body\n$BASHRC_FOOTER\n" >> ~/.bashrc
fi

################################################################################
## Create symbolic links to home directory
#
# Every thing in the $DOT_FILES/home directory is linked to user's home
# directory. Underscores are used for to escape dotfiles so they're not hidden
# in the $DOT_FILES directory.

echo "Updating sym links in home directory..."
USER_HOME=$HOME
CWD=$(pwd)
dirs_to_link=( "home" )
i=0
# loop because bash recursion is ... not great
while [ "$i" -lt "${#dirs_to_link[*]}" ]; do
    base_dir=${dirs_to_link[$i]}

    for file in $( ls_files "$base_dir" ); do
        dest_file=$( echo "$base_dir/$file" | sed "s#^home#${USER_HOME}#g")
        # remove symbolic links & back up existing files so we don't overwrite
        if [ -L "$dest_file" ]; then
            rm "$dest_file"
        elif [ -f "$dest_file" ]; then
            loginfo "Backing up $dest_file to ${dest_file}.bak"
            mv "$dest_file" "${dest_file}.bak"
        fi
        # create new link
        TARGET_DIR=$(dirname "$dest_file")
        mkdir -p "$TARGET_DIR"
        ln -s "$CWD/$base_dir/$file" "$dest_file"
    done

    # push any sub dirs onto the array of things left to do
    for _dir in $( ls_dirs "$base_dir" ); do
        dirs_to_link+=( "$base_dir/$_dir" )
    done

    ((i=i+1))
done

# TODO look for dead links in home directory pointing here
# find ~ -xtype l

################################################################################
## Run any other setup scripts

if [ -d setup_scripts ]; then
    echo "Running extra setup scripts"
    for initscript in $( ls_files setup_scripts ); do
        echo -e "###\n${initscript} ..."
        initscript_path="setup_scripts/$initscript"
        "./$initscript_path" || logfatal "Failed to run setup script: $initscript"
    done
fi

logok "Config updated! Run 'source ~/.bashrc' to update your current terminal."

