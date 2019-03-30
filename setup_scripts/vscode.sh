#!/usr/bin/env bash

set -eo pipefail

MY_PLUGINS=$(mktemp)

cat >"$MY_PLUGINS" <<EOF
castwide.solargraph
christian-kohler.path-intellisense
dbaeumer.vscode-eslint
eg2.tslint
esbenp.prettier-vscode
fabianlauer.vs-code-xml-format
fabiospampinato.vscode-todo-plus
formulahendry.auto-rename-tag
github.vscode-pull-request-github
ms-python.python
ms-vsliveshare.vsliveshare
naco-siren.gradle-language
PeterJausovec.vscode-docker
rebornix.ruby
robinbentley.sass-indented
streetsidesoftware.code-spell-checker
vscodevim.vim
timonwong.shellcheck
jpoissonnier.vscode-styled-components
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
