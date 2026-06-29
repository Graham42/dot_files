#!/usr/bin/env bash
# This script is to speed up setting up a new machine with my personal config

set -eo pipefail

THIS_SCRIPT="init_all.sh"

DRY_RUN=0
for arg in "$@"; do
    [ "$arg" = "--dry-run" ] && DRY_RUN=1
done

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
    loginfo "  Updating managed block in $rc_file"
    if [ "$DRY_RUN" -eq 1 ]; then
        logwarn "  [DRY RUN] Would update managed block in $rc_file"
        return
    fi
    touch "$rc_file"
    if grep -q "$BASHRC_HEADER" "$rc_file"; then
        BODY="$body" HEADER="$BASHRC_HEADER" FOOTER="$BASHRC_FOOTER" \
            perl -i -0777 -pe 's/\Q$ENV{HEADER}\E.*?\Q$ENV{FOOTER}\E/$ENV{HEADER}\n$ENV{BODY}\n$ENV{FOOTER}/s' \
            "$rc_file"
    else
        echo -e "\n$BASHRC_HEADER\n$body\n$BASHRC_FOOTER\n" >> "$rc_file"
    fi
}

loginfo "Updating shell rc files..."
update_rc_block ~/.bashrc bashrc_body.sh
update_rc_block ~/.zshrc zshrc_body.sh

################################################################################
## Create symbolic links to home directory
#
# Every thing in the $DOT_FILES/home directory is linked to user's home
# directory. Underscores are used for to escape dotfiles so they're not hidden
# in the $DOT_FILES directory.

loginfo "Updating symlinks in $HOME..."
USER_HOME=$HOME
CWD=$(pwd)

SKIP_FILE=".dotfiles_skip"
skip_list=()
if [ -f "$SKIP_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^#|^$ ]] && continue
        skip_list+=("$line")
    done < "$SKIP_FILE"
    loginfo "  Loaded ${#skip_list[@]} skip(s) from $SKIP_FILE"
fi

dirs_to_link=( "home" )
i=0
# loop because bash recursion is ... not great
while [ "$i" -lt "${#dirs_to_link[*]}" ]; do
    base_dir=${dirs_to_link[$i]}

    while IFS= read -r file; do
        dest_file=$( echo "$base_dir/$file" | sed "s#^home#${USER_HOME}#g")
        # check skip list (entries are relative to $HOME, e.g. .config/Code/User/settings.json)
        home_rel="${dest_file#${USER_HOME}/}"
        skip=0
        for skip_entry in "${skip_list[@]}"; do
            if [ "$home_rel" = "$skip_entry" ]; then
                skip=1; break
            fi
        done
        if [ "$skip" -eq 1 ]; then
            logwarn "  Skipping $dest_file (in .dotfiles_skip)"
            continue
        fi
        # remove symbolic links & back up existing files so we don't overwrite
        if [ -L "$dest_file" ]; then
            link_target=$(readlink "$dest_file")
            if [[ "$link_target" != "$CWD"* ]]; then
                logfatal "Symlink $dest_file points to $link_target (not in $CWD) — refusing to overwrite"
            fi
            [ "$DRY_RUN" -eq 0 ] && rm "$dest_file"
        elif [ -f "$dest_file" ]; then
            if [ "$DRY_RUN" -eq 1 ]; then
                logwarn "  [DRY RUN] Would back up $dest_file to ${dest_file}.bak"
            else
                logwarn "  Backing up $dest_file to ${dest_file}.bak"
                mv "$dest_file" "${dest_file}.bak"
            fi
        fi
        # create new link
        TARGET_DIR=$(dirname "$dest_file")
        if [ "$DRY_RUN" -eq 1 ]; then
            logwarn "  [DRY RUN] Would link $dest_file -> $CWD/$base_dir/$file"
        else
            mkdir -p "$TARGET_DIR"
            ln -s "$CWD/$base_dir/$file" "$dest_file"
            loginfo "  Linked $dest_file -> $CWD/$base_dir/$file"
        fi
    # process substitution (not a pipe) so the loop runs in this shell
    done < <( ls_files "$base_dir" )

    # push any sub dirs onto the array of things left to do
    while IFS= read -r _dir; do
        dirs_to_link+=( "$base_dir/$_dir" )
    done < <( ls_dirs "$base_dir" )

    ((i=i+1))
done

# TODO look for dead links in home directory pointing here
# find ~ -xtype l

################################################################################
## Run any other setup scripts

if [ -d setup_scripts ]; then
    loginfo "Running setup scripts..."
    while IFS= read -r initscript; do
        initscript_path="setup_scripts/$initscript"
        if [ "$DRY_RUN" -eq 1 ]; then
            logwarn "  [DRY RUN] Would run setup_scripts/$initscript"
        else
            loginfo "  Running setup_scripts/$initscript"
            "./$initscript_path" || logfatal "Failed: setup_scripts/$initscript"
        fi
    done < <( ls_files setup_scripts )
fi

if [ "$DRY_RUN" -eq 1 ]; then
    logwarn "Dry run complete. No changes were made."
else
    logok "Config updated! Run 'source ~/.bashrc' to update your current terminal."
fi
