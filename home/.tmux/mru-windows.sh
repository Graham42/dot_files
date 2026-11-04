#!/usr/bin/env bash
# Most Recently Used (MRU) window switcher: most recently accessed windows first.

# The binding supplies the originating pair so other clients cannot change it.
current_target=${1:-$(tmux display-message -p '#{session_id}:#{window_id}')}
filter="#{!=:#{session_id}:#{window_id},$current_target}"
if [ "${2:-}" = "--previous" ]; then
  # Skip aliases of the current window and windows with no recorded visit.
  filter="#{&&:#{!=:#{window_id},${current_target#*:}},#{>:#{@mru_access},0}}"
fi

session_count=$(tmux list-sessions 2>/dev/null | wc -l)

if [ "$session_count" -gt 1 ]; then
  # Multiple sessions: show session name prominently so it's searchable
  fmt="#{?@mru_access,#{@mru_access},0} #{session_name}:#{window_index} [#{session_name}] #{window_name}"
else
  # Single session: cleaner display without the session label
  fmt="#{?@mru_access,#{@mru_access},0} #{session_name}:#{window_index} #{window_name}"
fi

windows=$(
  tmux list-windows -a -f "$filter" \
    -F "$fmt" \
  | sort -rn \
  | sed 's/^[0-9]* //'
)

if [ "${2:-}" = "--previous" ]; then
  selected=${windows%%$'\n'*}
else
  selected=$(printf '%s\n' "$windows" | fzf-tmux -p -- --no-sort --layout=reverse)
fi

[ -z "$selected" ] && exit 0
tmux switch-client -t "${selected%% *}"
