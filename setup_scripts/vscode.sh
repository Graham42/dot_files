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
timonwong.shellcheck
jpoissonnier.vscode-styled-components
EOF

comm -23 <(sort -f "$MY_PLUGINS" | tr "[:upper:]" "[:lower:]") \
    <(code --list-extensions | sort -f | tr "[:upper:]" "[:lower:]") \
    | xargs -L1 code --install-extension

