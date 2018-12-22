#!/usr/bin/env bash
$(git rev-parse --verify -q $1 > /dev/null)
if [ $? != 0 ]; then
	echo 'Error: git-separation requires a valid branch name'
	echo 'Usage: git-separation <branch>'
	exit 1
fi
this_branch=$(git rev-parse --abbrev-ref HEAD)
ahead=$(git rev-list $this_branch --not $1 | wc -l)
behind=$(git rev-list $1 --not $this_branch | wc -l)
echo 'This branch is '$ahead' commits ahead, '$behind' commits behind '$1

