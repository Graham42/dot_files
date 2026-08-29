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
    # Don't log bare `ls`/`ll` (still logs `ls -la` etc, since HISTIGNORE
    # matches the whole line, not just the command name)
    export HISTIGNORE="ls:ll"
    # Unlimited history
    export HISTSIZE=-1
    export HISTFILESIZE=-1
    # Timestamp each entry (shown via `history`)
    export HISTTIMEFORMAT="%F %T "
    # Append to history on exit instead of overwriting
    shopt -s histappend
    # Write each command to the history file right away instead of only on
    # shell exit, so concurrent sessions don't lose/clobber each other's
    # history. Set before starship's init below, which preserves (rather
    # than overwrites) any PROMPT_COMMAND already set.
    PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
elif [ -n "$ZSH_VERSION" ]; then
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    setopt APPEND_HISTORY
    # Write each command to the history file right away instead of only on
    # shell exit, so concurrent sessions don't lose/clobber each other's
    # history
    setopt INC_APPEND_HISTORY
    # Live-sync history across all open sessions (implies INC_APPEND_HISTORY;
    # kept both for clarity)
    setopt SHARE_HISTORY
    # Timestamp each entry (zsh's equivalent of bash's HISTTIMEFORMAT)
    setopt EXTENDED_HISTORY
    # zsh's equivalent of HISTIGNORE: one glob pattern, alternatives in (a|b)
    export HISTORY_IGNORE="(ls|ll)"
    export HISTSIZE=1000000
    export SAVEHIST=1000000
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
# Agent CLIs (Claude)
# =============================================================================

# Launch claude with a specific model
alias claude-sonnet='claude --model claude-sonnet-5'
alias claude-opus='claude --model claude-opus-5'
alias claude-fable='claude --model claude-fable-5'

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
