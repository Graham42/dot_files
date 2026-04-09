#!/usr/bin/env bash
# Most Recently Used (MRU) window switcher: lists all tmux windows sorted by last activity (most recent first)
selected=$(
  tmux list-windows -a -f '#{!=:#{window_active},1}' \
    -F "#{window_activity} #{session_name}:#{window_index} #{window_name}" \
  | sort -rn \
  | sed 's/^[0-9]* //' \
  | fzf-tmux -p
)

[ -z "$selected" ] && exit 0
tmux switch-client -t "$(echo "$selected" | awk '{print $1}')"
