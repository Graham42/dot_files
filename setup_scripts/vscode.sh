#!/usr/bin/env bash

set -eo pipefail

MY_PLUGINS=$(mktemp)

cat >"$MY_PLUGINS" <<EOF
eamodio.gitlens
esbenp.prettier-vscode
golang.go
ms-azuretools.vscode-docker
ms-vsliveshare.vsliveshare
sdras.night-owl
silvenon.mdx
streetsidesoftware.code-spell-checker
timonwong.shellcheck
vscodevim.vim
EOF

MISSING_PLUGINS=$(
comm -23 \
    <(sort -f "$MY_PLUGINS" | tr "[:upper:]" "[:lower:]") \
    <(code --list-extensions | sort -f | tr "[:upper:]" "[:lower:]")
)

if [ -z "$MISSING_PLUGINS" ] ; then
    echo "All vscode plugins already installed"
else
    echo "$MISSING_PLUGINS" | xargs -L1 code --install-extension
fi

echo ""
echo "Extra vscode plugins installed:"
echo "---"
comm -23 \
    <(code --list-extensions | sort -f | tr "[:upper:]" "[:lower:]") \
    <(sort -f "$MY_PLUGINS" | tr "[:upper:]" "[:lower:]")
echo ""
