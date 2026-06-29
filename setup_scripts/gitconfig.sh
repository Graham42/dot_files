#!/usr/bin/env bash
# Ensures ~/.gitconfig exists and includes ~/.gitconfig_base at the top.
# ~/.gitconfig_base is symlinked from this dotfiles repo by init_all.sh.
# delta installation is handled by bootstrap/macos.sh and bootstrap/ubuntu.sh.
# bat is used by delta for syntax highlighting; its theme cache must be rebuilt
# when themes are added or changed (stored in home/.config/bat/themes/).

set -euo pipefail

MANAGED_HEADER="####################_BEGIN_DOT_FILES_GITCONFIG_######################"
MANAGED_FOOTER="#####################_END_DOT_FILES_GITCONFIG_#######################"
BLOCK_BODY="[include]
	path = ~/.gitconfig_base"
BLOCK="$(printf '%s\n%s\n%s\n\n' "$MANAGED_HEADER" "$BLOCK_BODY" "$MANAGED_FOOTER")"

GITCONFIG="$HOME/.gitconfig"

if [ ! -f "$GITCONFIG" ]; then
    echo "Creating $GITCONFIG with include for ~/.gitconfig_base"
    printf '%s' "$BLOCK" > "$GITCONFIG"
    echo "Add your machine-specific settings (e.g. [user]) to $GITCONFIG"
elif grep -q '_BEGIN_DOT_FILES_GITCONFIG_' "$GITCONFIG"; then
    echo "Updating managed block in $GITCONFIG"
    # -0777 slurps the whole file; \Q...\E quotes the markers literally; /s makes . match newlines
    HEADER="$MANAGED_HEADER" FOOTER="$MANAGED_FOOTER" BODY="$BLOCK_BODY" \
        perl -i -0777 -pe 's/\Q$ENV{HEADER}\E.*?\Q$ENV{FOOTER}\E/$ENV{HEADER}\n$ENV{BODY}\n$ENV{FOOTER}/s' \
        "$GITCONFIG"
elif grep -q 'path = ~/.gitconfig_base' "$GITCONFIG"; then
    echo "Upgrading $GITCONFIG to managed block (was unmanaged include)"
    # [ \t\n]+ tolerates any whitespace (spaces, tabs, blank lines) between [include] and path =
    HEADER="$MANAGED_HEADER" FOOTER="$MANAGED_FOOTER" BODY="$BLOCK_BODY" \
        perl -i -0777 -pe 's/\[include\][ \t\n]+path = ~\/\.gitconfig_base/$ENV{HEADER}\n$ENV{BODY}\n$ENV{FOOTER}/s' \
        "$GITCONFIG"
else
    echo "Prepending managed block to $GITCONFIG"
    tmp=$(mktemp)
    trap 'rm -f "$tmp"' EXIT
    { printf '%s' "$BLOCK"; cat "$GITCONFIG"; } > "$tmp"
    cp "$tmp" "$GITCONFIG"
fi

if command -v bat &>/dev/null; then
    echo "Rebuilding bat theme cache..."
    bat cache --build
else
    echo "bat is not installed — skipping theme cache build (install bat to enable delta syntax highlighting)"
fi
