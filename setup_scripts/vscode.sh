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
comm -23 \
    <(code --list-extensions | sort -f | tr "[:upper:]" "[:lower:]") \
    <(sort -f "$MY_PLUGINS" | tr "[:upper:]" "[:lower:]")
echo ""

# If we're in WSL we need to repeat the process, but with a subset of
# extensions. These can be found by opening VSCode after installing from the
# linux side and looking for plugins that have the option to "Install Locally"
if grep -i -q microsoft /proc/version; then
    echo "WSL detected, checking for more plugins..."

    cat >"$MY_PLUGINS" <<EOF
ms-vscode-remote.remote-wsl
sdras.night-owl
silvenon.mdx
vscodevim.vim
EOF

    # We have to use the powershell command Set-Location to prevent warnings
    # being printed about trying to start VSCode from the Windows side with a
    # linux current working directory
    MISSING_PLUGINS=$(
    comm -23 \
        <(sort -f "$MY_PLUGINS" | tr "[:upper:]" "[:lower:]") \
        <(powershell.exe "Set-Location -Path \"\$env:USERPROFILE\"; code --list-extensions" | sort -f | tr "[:upper:]" "[:lower:]")
    )
    if [ -z "$MISSING_PLUGINS" ] ; then
        echo "All vscode plugins already installed"
    else
        echo "$MISSING_PLUGINS" | xargs -I{} powershell.exe "Set-Location -Path \"\$env:USERPROFILE\"; code --install-extension {}"
    fi

    echo ""
    echo "Extra vscode plugins installed:"
    comm -23 \
        <(powershell.exe "Set-Location -Path \"\$env:USERPROFILE\"; code --list-extensions" | sort -f | tr "[:upper:]" "[:lower:]") \
        <(sort -f "$MY_PLUGINS" | tr "[:upper:]" "[:lower:]")
    echo ""
fi
