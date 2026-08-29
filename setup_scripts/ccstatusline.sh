#!/usr/bin/env bash
# Wires up Claude Code's statusLine to invoke ccstatusline
# (https://github.com/sirmalloc/ccstatusline), using the packageManager
# recorded in home/.config/ccstatusline/settings.json - the ccstatusline
# config checked into this repo and symlinked to
# ~/.config/ccstatusline/settings.json by init_all.sh's home/ symlink phase
# (which always runs before setup_scripts/, so that file is guaranteed to
# exist by the time this script runs as part of a normal init_all.sh run).
#
# Runs automatically every time init_all.sh runs (like every other
# setup_scripts/ script), right after the symlink phase. Can still be run
# standalone:
#   ./setup_scripts/ccstatusline.sh
#
# ccstatusline itself has no real "install" step in auto-update mode - `bunx
# -y ccstatusline@latest` (or `npx -y ccstatusline@latest`, depending on
# home/.config/ccstatusline/settings.json's installation.packageManager)
# fetches/caches the latest version on demand. This script just needs
# bun/npm on the machine (see bootstrap/linux/node.sh) and merges the right
# statusLine command into ~/.claude/settings.json.
#
# ~/.claude/settings.json is itself a symlink to this repo's
# home/.claude/settings.json, so the merge below writes straight into a
# tracked file - re-running init_all.sh after an upstream ccstatusline
# change, or after switching packageManager, shows up as a normal git diff
# there to review and commit. This is intentional, not a bug.
#
# Safe to re-run: always re-derives the statusLine command from
# home/.config/ccstatusline/settings.json's packageManager and re-merges it;
# any other keys already in ~/.claude/settings.json are left untouched.

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

CCSTATUSLINE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ccstatusline/settings.json"
if [ ! -f "$CCSTATUSLINE_CONFIG" ]; then
    echo "Missing $CCSTATUSLINE_CONFIG (expected to be symlinked from home/.config/ccstatusline/settings.json by init_all.sh's symlink phase), skipping ccstatusline setup."
    exit 0
fi

# Quick sanity check that bunx can resolve the package before we wire
# anything up to it. Best-effort: this script now runs unattended on every
# init_all.sh invocation, so a transient network hiccup here should skip
# just this script (via the `if` below, which doesn't trigger `set -e`),
# not abort the rest of init_all.sh. Real errors later in this script (e.g.
# jq failures) are still treated as fatal via `set -e`.
echo "Checking ccstatusline is reachable via bunx..."
if ! "$BUN" x -y ccstatusline@latest --version >/dev/null; then
    echo "Could not reach ccstatusline via bunx (network issue?) - skipping ccstatusline setup for this run." >&2
    exit 0
fi

# Wire up Claude Code's statusLine to invoke ccstatusline, using the package
# manager recorded in the checked-in config (bun -> bunx, npm -> npx). Merge
# into ~/.claude/settings.json rather than overwriting it wholesale, since
# that file holds other settings this repo doesn't (fully) manage.
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
[ -f "$CLAUDE_SETTINGS" ] || echo '{}' >"$CLAUDE_SETTINGS"

PACKAGE_MANAGER=$(jq -r '.installation.packageManager // "bun"' "$CCSTATUSLINE_CONFIG")
case "$PACKAGE_MANAGER" in
    bun) STATUSLINE_CMD="bunx -y ccstatusline@latest" ;;
    npm) STATUSLINE_CMD="npx -y ccstatusline@latest" ;;
    *)
        echo "Unrecognized installation.packageManager '$PACKAGE_MANAGER' in $CCSTATUSLINE_CONFIG, defaulting to bunx"
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
