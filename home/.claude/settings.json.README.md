# settings.json notes

Why each key in `settings.json` is set

For schema reference, see: https://docs.claude.com/en/docs/claude-code/settings

## tui: "default"

Prefer this so I can use tmux scrollback, and tmux resurrect features.

## attribution.sessionUrl: false

Skip appending the claude.ai session link to commits/PRs. To me this feels like a security incident waiting to happen if a session gets shared.

## showClearContextOnPlanAccept: true

Important for saving context. The plan file should hold everything and all the exploration that came before is a waste of tokens to keep in the window and can also bias and produce worse results.
