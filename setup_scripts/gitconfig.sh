#!/usr/bin/env bash
# Ensures ~/.gitconfig exists and includes ~/.gitconfig_base at the top.
# ~/.gitconfig_base is symlinked from this dotfiles repo by init_all.sh.

set -eo pipefail

INCLUDE_SECTION="[include]
	path = ~/.gitconfig_base"

GITCONFIG="$HOME/.gitconfig"

if [ ! -f "$GITCONFIG" ]; then
    echo "Creating $GITCONFIG with include for ~/.gitconfig_base"
    printf '%s\n\n' "$INCLUDE_SECTION" > "$GITCONFIG"
    echo "Add your machine-specific settings (e.g. [user]) to $GITCONFIG"
else
    if grep -q 'path = ~/.gitconfig_base' "$GITCONFIG"; then
        echo "$GITCONFIG already includes ~/.gitconfig_base, nothing to do"
    else
        echo "Prepending ~/.gitconfig_base include to $GITCONFIG"
        tmp=$(mktemp)
        printf '%s\n\n' "$INCLUDE_SECTION" | cat - "$GITCONFIG" > "$tmp"
        mv "$tmp" "$GITCONFIG"
    fi
fi
