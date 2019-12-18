#!/usr/bin/env bash

set -eo pipefail

MY_PLUGINS=$(mktemp)

cat >"$MY_PLUGINS" <<EOF
dbaeumer.vscode-eslint
eamodio.gitlens
esbenp.prettier-vscode
fabianlauer.vs-code-xml-format
fabiospampinato.vscode-markdown-todo
formulahendry.github-actions
github.vscode-pull-request-github
imperez.smarty
infarkt.css-to-jss
jpoissonnier.vscode-styled-components
mermade.openapi-lint
ms-azuretools.vscode-docker
ms-kubernetes-tools.vscode-kubernetes-tools
ms-python.python
ms-vscode.go
ms-vsliveshare.vsliveshare
naco-siren.gradle-language
rebornix.ruby
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
