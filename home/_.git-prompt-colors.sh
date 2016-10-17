#!/usr/bin/env bash
# Custom theme for https://github.com/magicmonty/bash-git-prompt

override_git_prompt_colors() {
  GIT_PROMPT_THEME_NAME="Custom"

  ## Various variables you might want for your PS1 prompt instead
  ## For a complete list see
  ## https://www.gnu.org/software/bash/manual/bashref.html#Printing-a-Prompt
  # Time12h="\T"
  # Time12a="\@"
  # Date="\d"
  # PathShort="\w"
  # PathFull="\W"
  # NewLine="\n"
  # Jobs="\j"
  # Hostname="\h"
  User="\u"

  ## These are the color definitions used by gitprompt.sh
  GIT_PROMPT_PREFIX=""
  GIT_PROMPT_SUFFIX=""
  GIT_PROMPT_SEPARATOR=" |"

  GIT_PROMPT_BRANCH="${Cyan}"      # the git branch that is active in the current directory
  GIT_PROMPT_STAGED=" ${Green}●"   # the number of staged files/directories
  GIT_PROMPT_CONFLICTS=" ${Red}✖"  # the number of files in conflict
  GIT_PROMPT_CHANGED=" ${Red}+"    # the number of changed files

  # GIT_PROMPT_REMOTE=" "             # the remote branch name (if any) and the symbols for ahead and behind
  GIT_PROMPT_UNTRACKED=" ${Cyan}…"    # the number of untracked files/dirs
  GIT_PROMPT_STASHED=" ${BoldBlue}⚑"  # the number of stashed files/dir
  GIT_PROMPT_CLEAN=" ${BoldGreen}✔ "  # a colored flag indicating a "clean" repo

  ## For the command indicator, the placeholder _LAST_COMMAND_STATE_
  ## will be replaced with the exit code of the last command
  GIT_PROMPT_COMMAND_OK="${Green}*"    # indicator if the last command returned with an exit code of 0
  GIT_PROMPT_COMMAND_FAIL="${Red}*"    # indicator if the last command returned with an exit code of other than 0

  ## _LAST_COMMAND_INDICATOR_ will be replaced by the appropriate GIT_PROMPT_COMMAND_OK OR GIT_PROMPT_COMMAND_FAIL
  GIT_PROMPT_START_USER="_LAST_COMMAND_INDICATOR_ ${White}${User} ${Green}${PathShort}${ResetColor}"
  GIT_PROMPT_START_ROOT="_LAST_COMMAND_INDICATOR_ ${Red}${User} ${Green}${PathShort}${ResetColor}"
  GIT_PROMPT_END_USER=" \n$ "
  GIT_PROMPT_END_ROOT=" \n${Red}#${ResetColor} "

  ## Do not add colors to these symbols
  GIT_PROMPT_SYMBOLS_AHEAD="↑"              # The symbol for "n versions ahead of origin"
  GIT_PROMPT_SYMBOLS_BEHIND="↓"             # The symbol for "n versions behind of origin" # GIT_PROMPT_SYMBOLS_PREHASH=":"            # Written before hash of commit, if no name could be found
  GIT_PROMPT_SYMBOLS_NO_REMOTE_TRACKING="?" # This symbol is written after the branch, if the branch is not tracked 
}

reload_git_prompt_colors "Custom"
