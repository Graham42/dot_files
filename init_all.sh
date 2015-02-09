#!/bin/bash
# This script is to speed up setting up a new VM with my personal config

function ls_type {
    if [ "${2}x" == "x" ]; then
        DIR=\.
    else
        DIR="$2"
    fi
    find $DIR -mindepth 1 -maxdepth 1 -type "$1" \( ! -iname ".*" \) | sed "s#^${DIR}/##g"
}
function ls_dirs {
    ls_type d $1
}
function ls_files {
    ls_type f $1
}
function error {
    echo "Error occured: "$1
    exit 1
}


# if header/footer are changed, will mess up auto-update
bashrc_header="####################_BEGIN_DOT_FILES_AUTOBLOCK_######################"
bashrc_footer="#####################_END_DOT_FILES_AUTOBLOCK_#######################"
bashrc_body=$( cat include_common.sh )

if $(grep "$bashrc_header" ~/.bashrc -q); then
    echo "Already initialized. Updating..."
    escaped_body=$(echo "$bashrc_body" | sed -e':a' -e'N' -e'$!ba' -e's/\n/\\n/g')
    sed -i'' -e"/^$bashrc_header$/,/^$bashrc_footer$/c $bashrc_header\n$escaped_body\n$bashrc_footer" ~/.bashrc
else
    echo "Initializing..."
    echo -e "\n" >> ~/.bashrc
    echo "$bashrc_header$bashrc_body$bashrc_footer" >> ~/.bashrc
    echo -e "\n" >> ~/.bashrc
fi

MY_HOME=$( echo ~ )
CWD=$(pwd)
dirs_todo=( "home" )
i=0
# loop because bash recursion is ... not great
while [ "$i" -lt "${#dirs_todo[*]}" ]; do
    base_dir=${dirs_todo[$i]}

    for _file in $( ls_files $base_dir ); do
        # remove leading '_'s
        file=$( echo $_file | sed 's#^_##g' )
        dest_file=$( echo $base_dir/$_file | sed "s#^home#${MY_HOME}#g" | sed "s#/_\.#/.#g")
        # remove symbolic links & back up existing files so we don't overwrite
        if [ -L $dest_file ]; then
            rm $dest_file
        elif [ -f $dest_file ]; then
            echo "Backing up $dest_file to ${dest_file}.bak"
            mv $dest_file ${dest_file}.bak
        fi
        # create new link
        ln -s $CWD/$base_dir/$_file $dest_file
    done

    # push any sub dirs on the main array
    for _dir in $( ls_dirs $base_dir ); do
        dirs_todo+=( "$base_dir/$_dir" )
    done

    ((i=i+1))
done

echo "Config updated! Run 'source ~/.bashrc' to update your current terminal."

