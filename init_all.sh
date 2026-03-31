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
## Create/update a managed block in shell rc files

# WARNING: if header/footer are changed, will mess up auto-update
BASHRC_HEADER="####################_BEGIN_DOT_FILES_AUTOBLOCK_######################"
BASHRC_FOOTER="#####################_END_DOT_FILES_AUTOBLOCK_#######################"

function update_rc_block {
    local rc_file="$1"
    local body_file="$2"
    if [ ! -e "$body_file" ]; then
        logfatal "Missing file '$body_file'"
    fi
    local body
    body=$(cat "$body_file")
    touch "$rc_file"
    echo "Updating block in $rc_file"
    if grep -q "$BASHRC_HEADER" "$rc_file"; then
        BODY="$body" HEADER="$BASHRC_HEADER" FOOTER="$BASHRC_FOOTER" \
            perl -i -0777 -pe 's/\Q$ENV{HEADER}\E.*?\Q$ENV{FOOTER}\E/$ENV{HEADER}\n$ENV{BODY}\n$ENV{FOOTER}/s' \
            "$rc_file"
    else
        echo -e "\n$BASHRC_HEADER\n$body\n$BASHRC_FOOTER\n" >> "$rc_file"
    fi
}

update_rc_block ~/.bashrc bashrc_body.sh
update_rc_block ~/.zshrc zshrc_body.sh

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
            logwarn "Backing up $dest_file to ${dest_file}.bak"
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
