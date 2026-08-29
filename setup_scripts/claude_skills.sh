#!/usr/bin/env bash
# Installs Claude Code skills via vercel-labs/skills (npx skills).
#
# vercel-labs/skills has no manifest/lockfile-driven install yet (see
# https://github.com/vercel-labs/skills/issues/283), so this list is this
# repo's stand-in for a config file: skills are declared here, one per line,
# and installed non-interactively.
#
# Each entry is a source (github shorthand, URL, or local path), optionally
# followed by `--skill <name...>` to install only specific skills rather than
# everything in that source.

set -eo pipefail

if ! command -v npx &>/dev/null; then
    echo "npx is not available, skipping Claude Code skills setup."
    echo "Install Node.js (see bootstrap/linux/node.sh) to enable this."
    exit 0
fi

SKILLS=(
    "mattpocock/skills --skill grill-me grilling tdd handoff"
    "petergyang/no-ai-slop --skill no-ai-slop"
    "kunchenguid/gh-axi --skill gh-axi"
    "kunchenguid/axi --skill axi"
)

for entry in "${SKILLS[@]}"; do
    echo "Installing skill(s): $entry"
    # shellcheck disable=SC2086 # $entry intentionally word-splits into args
    npx --yes skills add $entry --global --agent claude-code --yes
done

echo "Claude Code skills updated"
