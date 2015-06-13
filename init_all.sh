#!/bin/bash
# This script is to speed up setting up a new machine with my personal config

# Colors for nicer output
Color_Off="\033[0m"         # Text Reset
Red="\033[0;31m"            # Red
Green="\033[0;32m"          # Green
Yellow="\033[0;33m"         # Yellow

function ls_dirs {
    ls_type d $1
}
function ls_files {
    ls_type f $1
}
function ls_type {
    if [ "${2}x" == "x" ]; then
        DIR=\.
    else
        DIR="$2"
    fi
    find $DIR -mindepth 1 -maxdepth 1 -type "$1" \( ! -iname ".*" \) | sed "s#^${DIR}/##g"
}
function logok {
    echo -e "${Green}$@$Color_Off"
}
function loginfo {
    echo -e "${Cyan}$@$Color_Off"
}
function logwarn {
    echo -e "${Yellow}$@$Color_Off"
}
function logerror {
    echo -e "${Red}$@$Color_Off"
    exit 1
}


# WARNING: if header/footer are changed, will mess up auto-update
bashrc_header="####################_BEGIN_DOT_FILES_AUTOBLOCK_######################"
bashrc_footer="#####################_END_DOT_FILES_AUTOBLOCK_#######################"
if [ ! -e include_common.sh ]; then
    logerror "Missing file 'include_common.sh'"
fi
bashrc_body=$( cat include_common.sh )
# os specific things
if [ -d os_specific ]; then
    for os_file in $( ls_files os_specific ); do
        os_file_path="os_specific/$os_file"
        # header of each file determines if it this is the OS it's looking for
        if eval $( head -n2 $os_file_path | tail -n1  | sed "s/^#\+//g" ) ; then
            bashrc_body="$bashrc_body\n$( tail -n+3 "os_specific/$os_file" )"
        fi
    done
fi
# auto update the include block in ~/.bashrc
if $(grep "$bashrc_header" ~/.bashrc -q); then
    echo "Already initialized. Updating..."
    escaped_body=$(echo "$bashrc_body" | sed -e':a' -e'N' -e'$!ba' -e's/\n/\\n/g')
    sed -i'' -e"/^$bashrc_header$/,/^$bashrc_footer$/c $bashrc_header\n$escaped_body\n$bashrc_footer" ~/.bashrc
else
    echo "Initializing..."
    echo -e "\n$bashrc_header\n$bashrc_body\n$bashrc_footer\n" >> ~/.bashrc
fi

# create symbolic links to users home directory
USER_HOME=$( echo ~ )
CWD=$(pwd)
dirs_todo=( "home" )
i=0
# loop because bash recursion is ... not great
while [ "$i" -lt "${#dirs_todo[*]}" ]; do
    base_dir=${dirs_todo[$i]}

    for _file in $( ls_files $base_dir ); do
        # remove leading '_'s
        file=$( echo $_file | sed 's#^_##g' )
        dest_file=$( echo $base_dir/$_file | sed "s#^home#${USER_HOME}#g" | sed "s#/_\.#/.#g")
        # remove symbolic links & back up existing files so we don't overwrite
        if [ -L $dest_file ]; then
            rm $dest_file
        elif [ -f $dest_file ]; then
            loginfo "Backing up $dest_file to ${dest_file}.bak"
            mv $dest_file ${dest_file}.bak
        fi
        # create new link
        if [ -d $(dirname $dest_file) ]; then
            ln -s $CWD/$base_dir/$_file $dest_file
        else
            logwarn "$(basename $dest_file) not linked because folder does not exist. Maybe this program is not installed?"
        fi
    done

    # push any sub dirs onto the todo array
    for _dir in $( ls_dirs $base_dir ); do
        dirs_todo+=( "$base_dir/$_dir" )
    done

    ((i=i+1))
done

if [ -d setup_scripts ]; then
    echo "Running extra setup scripts..."
    for initscript in $( ls_files setup_scripts ); do
        initscript_path="setup_scripts/$initscript"
        ./$initscript_path || logerror "Failed to run setup script: $initscript"
    done
fi

logok "Config updated! Run 'source ~/.bashrc' to update your current terminal."

