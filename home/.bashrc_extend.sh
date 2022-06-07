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
alias now='date +%Y-%m-%dT%H:%M:%S'


# This line needs to stay exactly like this except if changed by the bash
# light_mode/dark_mode functions.
export COLOR_SCHEME=DARK

_color_mode() {
    # should be LIGHT or DARK
    NEW=$1
    if [ "$NEW" == "LIGHT" ] ; then
        OLD="DARK"
        VS_THEME="Night Owl Light"
    else
        OLD="LIGHT"
        NEW="DARK"
        VS_THEME="Night Owl"
    fi

    # Hyper config
    sed --follow-symlinks -i 's/const COLOR_SCHEME = "'$OLD'"/const COLOR_SCHEME = "'$NEW'"/' ~/.hyper.js

    # bashrc
    sed --follow-symlinks -i 's/export COLOR_SCHEME='$OLD'/export COLOR_SCHEME='$NEW'/' ~/.bashrc_extend.sh

    # VS Code Settings
    node -e "const targetFile = process.env.HOME + '/.config/Code/User/settings.json';
const vsCodeSettings = require(targetFile);
vsCodeSettings['workbench.colorTheme'] = '$VS_THEME';

require('fs').writeFileSync(targetFile, JSON.stringify (vsCodeSettings, null, 2), 'utf8');"
    npx prettier --write ~/.config/Code/User/settings.json

    # Current tmux sessions
    for _pane in $(tmux list-panes -a -F '#{pane_id}'); do
        # save us from Vim
        tmux send-keys -t "$_pane" Escape Escape Escape C-z
        # give time to end up in process
        sleep 0.3s
        tmux send-keys -t "$_pane" "export COLOR_SCHEME=$NEW" Enter
        # go back to what we were doing
        tmux send-keys -t "$_pane" '%' Enter
    done
}
light_mode () {
    _color_mode "LIGHT"
}
dark_mode () {
    _color_mode "DARK"
}


# =============================================================================
## Prompt

eval "$(starship init bash)"

# =============================================================================

# environment vars needed for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev
source virtualenvwrapper.sh > /dev/null 2>&1

