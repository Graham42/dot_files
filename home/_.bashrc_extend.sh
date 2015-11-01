#!/bin/bash

export EDITOR=vim
# save more history
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend

type vimx >/dev/null 2>&1 && alias vim='vimx'

# =============================================================================
# Aliases
# =============================================================================

alias ls='ls --color=auto -hv --group-directories-first'
alias la='ls -A'
alias l.='la -I"*"'
ListLongArgs=' -l --time-style=long-iso'
alias ll='ls $ListLongArgs'
alias lla='la $ListLongArgs'
alias ll.='l. $ListLongArgs'

# enable git completion
. ~/.git-completion.bash

# datetimestamp of now. ISO format except no timezone. Good for log file names
# example usage: process_x > degug_`nowf`.log
alias now='date +%Y-%m-%dT%H:%M:%S'


# =============================================================================
# Custom bash functions
# =============================================================================

# shell routine to do something in between a stash and a pop
git_stash_and_pop() {
	git stash && "$@" && git stash pop
}
alias gsp='git_stash_and_pop'

git_stash_apply_X() {
	stash=""
	if [ $# -eq 1 ]; then
		stash="stash@{$1}"
	fi
	git stash apply $stash
}
alias gsa='git_stash_apply_X'

function foreach_dir(){
    for arg in $(ls --color=none); do
        if [ -d "$arg" ] ; then
            cd $arg
            eval $@
            cd ..
        fi
    done
}

function foreach_dir-threaded(){
    for arg in $(ls --color=none); do
        if [ -d "$arg" ] ; then
            cd $arg
            $@ >/dev/null 2>&1 &
            cd ..
        fi
    done
    echo "Started..."
    wait
    echo "Done!"
}


# =============================================================================
# Bash Prompt (PS1)
# =============================================================================

# bash prompt inspired by https://gist.github.com/jameh/9039278

# bash git script can be found at
# https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh
. ~/.git-prompt.sh

# import a bunch of predefined colors
. ~/.colors.sh

# Various variables you might want for your PS1 prompt instead
# For a complete list see https://www.gnu.org/software/bash/manual/bashref.html#Printing-a-Prompt
Time12h="\T"
Time12a="\@"
Date="\d"
PathShort="\w"
PathFull="\W"
NewLine="\n"
Jobs="\j"
Hostname="\h"
User="\u"

c="\[\033["
n="${c}m\]"
# Color green/red depending on last command sucess
PS1="$n${c}1;3\$(if [ \$? -eq 0 ]; then echo '2'; else echo '1'; fi);40m\]*$n"
# Dynamically pick color for hostname
hostname_crc=$(echo $HOSTNAME | sha1sum | cut -c1-6)
hostcolor_a=$(( (0x${hostname_crc} + 1) % 2 ))
hostcolor_b=$(( (0x${hostname_crc} + 1) % 8 + 30 ))
hostcolor_c=$( if [ $hostcolor_b -le 31 ]; then echo 47 ; else echo 40; fi )
PS1="$PS1 ${c}37;40m\]$User${c}${hostcolor_a};${hostcolor_b};${hostcolor_c}m\]@$Hostname$n"
PS1="$PS1 ${c}1;34;40m\]$PathShort$n"
GIT_PART='$(git branch &>/dev/null;\
if [ $? -eq 0 ]; then \
  echo " $(
    # Check the stash
    n_lines=$(git stash list 2> /dev/null | wc --lines); \
    for (( c=0; c<n_lines; c++ ))
    do
      echo -n "'$Red'"$(__git_ps1 "*"'$Color_Off'); \
    done; \
	# Check the status
    status=$( git status 2>&1 ); \
    echo $status | grep "nothing to commit" > /dev/null 2>&1; \
    if [ "$?" -eq "0" ]; then \
      # @4 - Clean repository - nothing to commit
      echo "'$Green'"$(__git_ps1 "(%s)"'$Color_Off'); \
    else \
      echo $status | grep "nothing added to commit but untracked files present" > /dev/null 2>&1; \
      if [ "$?" -eq "0" ]; then \
        # Untracked files exist
        echo "'$Cyan'"$(__git_ps1 "{%s}"'$Color_Off'); \
      else \
        # @5 - Changes to working tree
        echo "'$Red'"$(__git_ps1 "{%s}"'$Color_Off'); \
      fi;
    fi;
  )"; \
fi)'
# Show red carot if root user
export PS1="${PS1}${GIT_PART}${c}\$(if [ ${EUID} -eq 0 ]; then echo '1;31'; else echo '0;37'; fi)m\] \$$n "

# =============================================================================

# syntax highlighting in less: requires source-highlight to be installed
if [ -f "/usr/bin/src-hilite-lesspipe.sh" ]; then
	export LESS="-R"
    export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
fi

# environment vars needed for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev
source virtualenvwrapper.sh > /dev/null 2>&1

