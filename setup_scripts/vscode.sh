#!/usr/bin/env bash

set -exo pipefail

MY_PLUGINS=$(mktemp)

cat >"$MY_PLUGINS" <<EOF
castwide.solargraph
christian-kohler.npm-intellisense
christian-kohler.path-intellisense
dbaeumer.vscode-eslint
eg2.tslint
esbenp.prettier-vscode
fabianlauer.vs-code-xml-format
fabiospampinato.vscode-todo-plus
formulahendry.auto-close-tag
formulahendry.auto-rename-tag
ms-python.python
ms-vsliveshare.vsliveshare
naco-siren.gradle-language
PeterJausovec.vscode-docker
rebornix.Ruby
robinbentley.sass-indented
streetsidesoftware.code-spell-checker
vscodevim.vim
EOF

comm -23 <(code --list-extensions | sort) <(sort "$MY_PLUGINS") | xargs -L1 code --uninstall-extension

xargs -L1 code --install-extension <"$MY_PLUGINS"

