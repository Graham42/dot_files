#!/usr/bin/env bash
# Most Recently Used (MRU) window switcher: lists all tmux windows sorted by last activity (most recent first)

session_count=$(tmux list-sessions 2>/dev/null | wc -l)

if [ "$session_count" -gt 1 ]; then
  # Multiple sessions: show session name prominently so it's searchable
  fmt="#{window_activity} #{session_name}:#{window_index} [#{session_name}] #{window_name}"
else
  # Single session: cleaner display without the session label
  fmt="#{window_activity} #{session_name}:#{window_index} #{window_name}"
fi

selected=$(
  tmux list-windows -a \
    -F "$fmt" \
  | sort -rn \
  | sed 's/^[0-9]* //' \
  | fzf-tmux -p
)

[ -z "$selected" ] && exit 0
tmux switch-client -t "$(echo "$selected" | awk '{print $1}')"
