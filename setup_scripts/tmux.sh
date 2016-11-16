#!/usr/bin/env bash
TMUX_PLUGIN_HOME=~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ${TMUX_PLUGIN_HOME} --depth=1 2>/dev/null || \
    (cd ${TMUX_PLUGIN_HOME} && git pull)

tmux source-file ~/.tmux.conf

${TMUX_PLUGIN_HOME}/bin/install_plugins
${TMUX_PLUGIN_HOME}/bin/update_plugins all

if $(uname -s | grep -q Linux) ; then
    if ! which xclip > /dev/null ; then
        echo "You may need to install xclip for tmux to be able to copy to the system clipboard"
    fi
fi

tmux source-file ~/.tmux.conf
