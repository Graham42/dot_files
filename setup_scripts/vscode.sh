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

# TODO don't launch if there's nothing to remove
comm -23 <(code --list-extensions | sort) <(sort "$MY_PLUGINS") | xargs -L1 code --uninstall-extension

# TODO only install what's needed
xargs -L1 code --install-extension <"$MY_PLUGINS"

