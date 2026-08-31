# bootstrap/linux

Setup scripts for a dev laptop. Two targets:

- **Ubuntu 26.04** (`/etc/os-release` says Ubuntu 26.04.1 LTS).
- **Linux Mint 22**, on the Ubuntu 24.04 base - the current Mint release, so it is what a Mint machine runs today. Mint 23 (Ubuntu 26.04 base) is not out yet, expected ~Dec 2026; the Mint paths here are written for it but untested. See the note at the top of `mint-desktop.sh`.

Keep both targets working.

## Principles

Scripts should be rerunnable. A second run updates rather than breaks or duplicates.

Scripts should pass `shellcheck -x *.sh` with no output; keep it that way, and where a warning has to be suppressed use an inline `# shellcheck disable=` with the reason.

Prefer progress discovery about a script with
- a single line description in the README.md of what a script is and when someone would want to use it.
- `--help` details once the script is run, printing a usage block

**`--uninstall` if the script changed something reversible** - it should undo what the script did.

## Constraints

- **The root `CLAUDE.md` rule that scripts work across macOS and Linux does not apply here.** This directory is for Linux, not macOS.
