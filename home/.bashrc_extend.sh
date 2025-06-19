#!/usr/bin/env bash

export EDITOR=vim
export SUDO_EDITOR=vim

# don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth
# save more history
export HISTSIZE=-1
export HISTFILESIZE=-1
# Append to bash history on shell exit instead of overwrite
shopt -s histappend

# =============================================================================
# Aliases
# =============================================================================

alias ls='ls --color=auto -hv --group-directories-first'
alias la='ls -A'
alias l.='la -I"*"'
alias ll='ls -l --time-style=long-iso'

# Force tmux to assume terminal supports 256 colours
alias tmux='tmux -2'

# if vimx is installed use it instead of vim so can copy to system clipboard
type vimx >/dev/null 2>&1 && alias vim='vimx'

# datetimestamp of now. ISO format except no timezone. Good for log file names
# example usage: process_x > degug_`nowf`.log
alias now='date +%Y-%m-%dT%H:%M:%S%z'

# =============================================================================
## Prompt

eval "$(starship init bash)"

# =============================================================================

# environment vars needed for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev
export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
# Lazy load for faster shell startup
if [ -f /usr/local/bin/virtualenvwrapper_lazy.sh ]; then
    source /usr/local/bin/virtualenvwrapper_lazy.sh
fi
