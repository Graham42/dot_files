#!/bin/bash

alias ls='ls --color=auto -hv --group-directories-first'
alias la='ls -A'
alias l.='la -I"*"'
ListLongArgs=' -l --time-style=long-iso'
alias ll='ls $ListLongArgs'
alias lla='la $ListLongArgs'
alias ll.='l. $ListLongArgs'

# make completion work with aliases
. ~/.git-completion.bash
alias gil='git log --graph --abbrev-commit --stat --find-copies --date=local --decorate '
__git_complete gil _git_log
alias gib='git branch'
__git_complete gib _git_branch
alias gis='git status'
alias gid='git diff -C --date=local'
__git_complete gid _git_diff
alias gic='git checkout'
__git_complete gic _git_checkout
alias g6='git short -6'

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

# bash prompt inspired by https://gist.github.com/jameh/9039278

# bash git script can be found at
# https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh
. ~/.git-prompt.sh

# import a bunch of predefined colors
. ~/.colors.sh

# Fix directory color on dark background
LS_COLORS="di=$BIBlue"
export LS_COLORS
eval "`dircolors`"

# Various variables you might want for your PS1 prompt instead
# For a complete list see https://www.gnu.org/software/bash/manual/bashref.html#Printing-a-Prompt
Time12h="\T"
Time12a="\@"
PathShort="\w"
PathFull="\W"
NewLine="\n"
Jobs="\j"
Hostname="\h"

export PS1=$Hostname':$(git branch &>/dev/null;\
if [ $? -eq 0 ]; then \
  echo "'$IBlue$PathShort$Color_Off'$(
    echo -n " "; \
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
  ) $ "; \
else \
  # @2 - Prompt when not in GIT repo
  echo "'$IBlue$PathShort$Color_Off' $ "; \
fi)'
