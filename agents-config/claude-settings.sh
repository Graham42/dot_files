#!/usr/bin/env bash
# Applies general Claude Code preferences (model, theme, etc.) from the
# checked-in agents-config/claude-settings.json into ~/.claude/settings.json.
#
# This is a standalone script, not run automatically by init_all.sh (unlike
# setup_scripts/) - run it manually when you want to (re)apply the config:
#   ./agents-config/claude-settings.sh
#
# Merges (rather than overwrites) ~/.claude/settings.json, since that file
# also holds other user settings this repo doesn't manage - including
# "statusLine", which agents-config/ccstatusline.sh manages separately (it
# needs to pick bunx vs npx at apply-time, so it isn't a static value here).
#
# Safe to re-run: always syncs the keys in claude-settings.json into
# ~/.claude/settings.json, so local edits to those same keys (e.g. via
# `claude config`) get overwritten next time this script runs. Any other
# keys already in ~/.claude/settings.json are left untouched.

set -euo pipefail

if ! command -v jq &>/dev/null; then
    echo "jq is not installed, skipping claude-settings setup. Run bootstrap/ubuntu.sh first"
    exit 0
fi

# resolve path relative to this script so it works regardless of cwd
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_CONFIG="$SCRIPT_DIR/claude-settings.json"

if [ ! -f "$SRC_CONFIG" ]; then
    echo "Missing $SRC_CONFIG, skipping claude-settings setup."
    exit 0
fi

CLAUDE_SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
[ -f "$CLAUDE_SETTINGS" ] || echo '{}' >"$CLAUDE_SETTINGS"

echo "Merging Claude Code settings -> $CLAUDE_SETTINGS"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
jq -s '.[0] * .[1]' "$CLAUDE_SETTINGS" "$SRC_CONFIG" >"$tmp"
cp "$tmp" "$CLAUDE_SETTINGS"

echo "Claude Code settings applied"
