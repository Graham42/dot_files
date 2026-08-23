#!/usr/bin/env sh
# Sourced by both ~/.bashrc and ~/.zshrc

export EDITOR=vim
export SUDO_EDITOR=vim

# =============================================================================
# History
# =============================================================================

if [ -n "$BASH_VERSION" ]; then
    # Don't put duplicate lines or lines starting with space in the history
    export HISTCONTROL=ignoreboth
    # Unlimited history
    export HISTSIZE=-1
    export HISTFILESIZE=-1
    # Append to history on exit instead of overwriting
    shopt -s histappend
elif [ -n "$ZSH_VERSION" ]; then
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    setopt APPEND_HISTORY
    export HISTSIZE=100000
    export SAVEHIST=100000
fi

# =============================================================================
# Aliases
# =============================================================================

if [ "$(uname)" = "Darwin" ]; then
    alias ls='gls --color=auto -hv --group-directories-first'
else
    alias ls='ls --color=auto -hv --group-directories-first'
fi
alias la='ls -A'
alias l.='la -I"*"'
alias ll='ls -l --time-style=long-iso'

# Force tmux to assume terminal supports 256 colours
alias tmux='tmux -2'

# if vimx is installed use it instead of vim so can copy to system clipboard
type vimx >/dev/null 2>&1 && alias vim='vimx'

# datetimestamp of now. ISO format except no timezone. Good for log file names
# example usage: process_x > debug_`nowf`.log
alias now='date +%Y-%m-%dT%H:%M:%S%z'

# =============================================================================
# Node.js (fnm)
# =============================================================================

# fnm is installed via `cargo install --locked fnm` (see bootstrap/linux/node.sh),
# so it lands in ~/.cargo/bin - already on PATH via rustup's own shell setup
if command -v fnm >/dev/null 2>&1; then
    # --use-on-cd auto-switches node version on `cd` into a dir with a
    # .nvmrc/.node-version file. Not gated behind the interactive-only check
    # below since scripts/tools may need node on PATH too, and unlike nvm,
    # fnm's shell hook is cheap enough not to matter for startup time.
    if [ -n "$ZSH_VERSION" ]; then
        eval "$(fnm env --use-on-cd --shell zsh)"
    elif [ -n "$BASH_VERSION" ]; then
        eval "$(fnm env --use-on-cd --shell bash)"
    fi
fi

# =============================================================================
# Interactive-only tools (skip in agent/non-interactive shells)
# =============================================================================

case "$-" in
    *i*)
        # Prompt
        if [ -n "$ZSH_VERSION" ]; then
            eval "$(starship init zsh)"
        elif [ -n "$BASH_VERSION" ]; then
            eval "$(starship init bash)"
        fi

        # cd (zoxide)
        if command -v zoxide >/dev/null 2>&1; then
            if [ -n "$ZSH_VERSION" ]; then
                eval "$(zoxide init zsh)"
            elif [ -n "$BASH_VERSION" ]; then
                eval "$(zoxide init bash)"
            fi
        fi
        ;;
esac
