# OS check:
# cat /etc/*-release | grep '^CentOS release 5' -q
#####
# Centos 5 specific things
# Fix directory color on dark background
LS_COLORS="di=$BIBlue"
export LS_COLORS
eval "`dircolors`"
# no support for --group-directories-first
alias ls='ls --color -hv'

