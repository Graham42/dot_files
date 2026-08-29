---
name: check-bootstrap
description: Audit this machine against dot_files/bootstrap (mainly the linux/*.md docs) and report what's missing or out of date. Use when the user asks if a machine/computer is fully set up, or to check/verify bootstrap.
---

Check whether this machine has everything `bootstrap/` (README.md and any OS-specific subdir, e.g. `bootstrap/linux/`) says it should, and report gaps concisely.

1. Read the relevant `bootstrap/<os>/README.md` and any other `.md` files there (e.g. `laptop-battery.md`, `wip-revised-setup-notes.md`) for documented manual steps and expected end state.
2. Skim `git log --oneline -20` on those directories/scripts for recent changes that may not have been applied yet (a script edited after it was last run).
3. For each item, verify on the live system (installed packages, `gsettings`, systemd units/services, symlinks, config files, running daemons) rather than assuming a script ran just because it exists.
4. Report as a short checklist: ✅ done / ❌ missing / ⚠️ needs manual action, with the exact command to fix each gap. Skip long narration — the checklist is the deliverable.
