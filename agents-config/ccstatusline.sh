#!/usr/bin/env bash
# Installs/configures ccstatusline (https://github.com/sirmalloc/ccstatusline)
# for Claude Code, importing the config checked in alongside this script at
# agents-config/ccstatusline-config.json.
#
# This is a standalone script, not run automatically by init_all.sh (unlike
# setup_scripts/) - run it manually when you want to (re)apply the config:
#   ./agents-config/ccstatusline.sh
#
# ccstatusline has no real "install" step in auto-update mode - `bunx -y
# ccstatusline@latest` fetches/caches the latest version on demand, which is
# what the exported config's installation.method "auto-update" +
# packageManager "bun" record. This script just needs bun on the machine (see
# bootstrap/linux/node.sh) and:
#   1. copies the checked-in settings to ~/.config/ccstatusline/settings.json
#   2. points Claude Code's statusLine at ccstatusline in ~/.claude/settings.json
#
# Safe to re-run: both steps always sync from this repo's config, so local
# edits made via the ccstatusline TUI directly will be overwritten next time
# this script runs.

set -euo pipefail

if ! command -v jq &>/dev/null; then
    echo "jq is not installed, skipping ccstatusline setup. Run bootstrap/ubuntu.sh first"
    exit 0
fi

# Find bun even in a non-interactive shell that hasn't sourced ~/.bashrc yet -
# the bun installer appends its own PATH line there directly rather than
# going through bashrc_body.sh (see bootstrap/linux/node.sh).
if command -v bun &>/dev/null; then
    BUN=bun
elif [ -x "$HOME/.bun/bin/bun" ]; then
    BUN="$HOME/.bun/bin/bun"
else
    echo "bun is not installed, skipping ccstatusline setup. See bootstrap/linux/node.sh (or https://bun.sh) to install it."
    exit 0
fi

# resolve path relative to this script so it works regardless of cwd
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_CONFIG="$SCRIPT_DIR/ccstatusline-config.json"

if [ ! -f "$SRC_CONFIG" ]; then
    echo "Missing $SRC_CONFIG, skipping ccstatusline setup."
    exit 0
fi

# quick sanity check that bunx can resolve the package before we wire
# anything up to it
echo "Checking ccstatusline is reachable via bunx..."
"$BUN" x -y ccstatusline@latest --version >/dev/null

CCSTATUSLINE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ccstatusline"
DEST_CONFIG="$CCSTATUSLINE_DIR/settings.json"

mkdir -p "$CCSTATUSLINE_DIR"
echo "Importing ccstatusline config -> $DEST_CONFIG"
cp "$SRC_CONFIG" "$DEST_CONFIG"

# Wire up Claude Code's statusLine to invoke ccstatusline, using the package
# manager recorded in the exported config (bun -> bunx, npm -> npx). Merge
# into ~/.claude/settings.json rather than overwriting it wholesale, since
# that file holds other user settings this repo doesn't manage.
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
[ -f "$CLAUDE_SETTINGS" ] || echo '{}' >"$CLAUDE_SETTINGS"

PACKAGE_MANAGER=$(jq -r '.installation.packageManager // "bun"' "$SRC_CONFIG")
case "$PACKAGE_MANAGER" in
    bun) STATUSLINE_CMD="bunx -y ccstatusline@latest" ;;
    npm) STATUSLINE_CMD="npx -y ccstatusline@latest" ;;
    *)
        echo "Unrecognized installation.packageManager '$PACKAGE_MANAGER' in $SRC_CONFIG, defaulting to bunx"
        STATUSLINE_CMD="bunx -y ccstatusline@latest"
        ;;
esac

echo "Setting statusLine command in $CLAUDE_SETTINGS"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
jq --arg cmd "$STATUSLINE_CMD" \
    '.statusLine = {"type": "command", "command": $cmd, "padding": 0, "refreshInterval": 10}' \
    "$CLAUDE_SETTINGS" >"$tmp"
cp "$tmp" "$CLAUDE_SETTINGS"

echo "ccstatusline configured (command: $STATUSLINE_CMD)"
