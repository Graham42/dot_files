#!/usr/bin/env bash

export EDITOR=vim
export SUDO_EDITOR=vim

# save more history
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend

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

alias tmux='tmux -2'

# if vimx is installed use it instead of vim so can copy to system clipboard
type vimx >/dev/null 2>&1 && alias vim='vimx'

# enable git completion
. ~/.git-completion.bash

# datetimestamp of now. ISO format except no timezone. Good for log file names
# example usage: process_x > degug_`nowf`.log
alias now='date +%Y-%m-%dT%H:%M:%S'

alias cl='clear'

# =============================================================================
# Custom bash functions
# =============================================================================

# shell routine to do something in between a stash and a pop
git_stash_and_pop() {
	git stash && "$@" && git stash pop
}
alias gsp='git_stash_and_pop'

# apply stash at index X
git_stash_apply_X() {
	stash=""
	if [ $# -eq 1 ]; then
		stash="stash@{$1}"
	fi
	git stash apply $stash
}
alias gsa='git_stash_apply_X'

# do something in each subfolder, excludes hidden folders
function foreach_dir(){
    for arg in $(ls --color=none); do
        if [ -d "$arg" ] ; then
            cd $arg
            eval $@
            cd ..
        fi
    done
}

# do something in each subfolder in parralell, excludes hidden folders
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

# Using https://github.com/magicmonty/bash-git-prompt
GIT_PROMPT_THEME=Custom
GIT_PROMPT_THEME_FILE=~/.git-prompt-colors.sh

source ~/.bash-git-prompt/gitprompt.sh

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

