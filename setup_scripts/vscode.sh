#!/usr/bin/env bash

set -exo pipefail

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
EOF

alias to_lower="tr [A-Z] [a-z]"

comm -23 <(sort -f "$MY_PLUGINS" | to_lower) \
    <(code --list-extensions | sort -f | to_lower) \
    | xargs -L1 code --install-extension

