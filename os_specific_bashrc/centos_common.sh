# OS check:
# cat /etc/*-release 2>/dev/null | grep '^CentOS' -q
#####
# Centos specific things
# Fix directory color on dark background
BIBlue="\[\033[1;94m\]"
LS_COLORS="di=$BIBlue"
export LS_COLORS
eval "`dircolors`"

