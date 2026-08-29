#!/usr/bin/env bash
# Refresh LVFS metadata and report available firmware updates.
#
# Read-only: this never flashes anything. To apply what it finds, run
# `fwupdmgr update` yourself (plug in AC power first - a UEFI/BIOS payload
# reboots into an EFI applet to do the flash).
#
# Usage: firmware-update.sh [--force]
#
#   --force   Pass --force to `fwupdmgr refresh`, re-downloading the LVFS
#             metadata even if it is less than RefreshInterval (default 24h)
#             old. Not normally needed: fwupd's own fwupd-refresh.timer
#             already refreshes roughly daily, so the cache is usually fresh
#             and a plain run just reuses it.
#
# Linux only - fwupd has no macOS equivalent.

set -uo pipefail

# fwupdmgr exit codes, from src/fu-util-common.h upstream:
#   0 = success, 1 = failure, 2 = nothing to do, 3 = not found,
#   101 = network unreachable (ENETUNREACH).
# fwupd's own fwupd-refresh.service whitelists 2 and 101 via
# SuccessExitStatus, which is a good hint about how routine they are.
readonly EXIT_NOTHING_TO_DO=2
readonly EXIT_NOT_FOUND=3
readonly EXIT_NOT_REACHABLE=101

force=0
while [ $# -gt 0 ]; do
    case "$1" in
        -f|--force)
            force=1
            ;;
        -h|--help)
            sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "firmware-update.sh: unknown argument '$1'" >&2
            echo "Usage: firmware-update.sh [--force]" >&2
            exit 1
            ;;
    esac
    shift
done

if [ "$(uname -s)" != "Linux" ]; then
    echo "firmware-update.sh: Linux only (fwupd is not available on $(uname -s))" >&2
    exit 1
fi

if ! command -v fwupdmgr >/dev/null 2>&1; then
    echo "firmware-update.sh: fwupdmgr not found. Install it with:" >&2
    echo "    sudo apt install fwupd" >&2
    exit 1
fi

echo "=== fwupd ==="
fwupdmgr --version 2>/dev/null | grep -E '^runtime[[:space:]]+org\.freedesktop\.fwupd' || true

echo
echo "=== Refreshing LVFS metadata ==="
refresh_args=(refresh)
[ "${force}" -eq 1 ] && refresh_args+=(--force)
fwupdmgr "${refresh_args[@]}"
refresh_status=$?

case ${refresh_status} in
    0) ;;
    "${EXIT_NOTHING_TO_DO}")
        # fwupd rate-limits refreshes to one per RefreshInterval (24h by
        # default) and already prints "Metadata is up to date; use --force to
        # refresh again." on stderr, so don't repeat it. The cached metadata
        # is used as-is, which is the point of not passing --force.
        ;;
    "${EXIT_NOT_REACHABLE}")
        echo >&2
        echo "firmware-update.sh: network unreachable - could not reach fwupd.org." >&2
        exit "${refresh_status}"
        ;;
    *)
        echo >&2
        echo "firmware-update.sh: refresh failed (exit ${refresh_status})." >&2
        echo "Check network access to fwupd.org. If this is an SSH or other" >&2
        echo "non-desktop session polkit may not be able to prompt - retry with:" >&2
        echo "    sudo fwupdmgr refresh" >&2
        exit "${refresh_status}"
        ;;
esac

echo
echo "=== Available updates ==="

# Prefer the JSON output: it is exact about which devices actually have a
# pending release. The human-readable output interleaves an informational
# "Devices with no available firmware updates:" section with the real
# updates, which is far too easy to misread.
updates_json=""
if command -v jq >/dev/null 2>&1; then
    updates_json=$(fwupdmgr get-updates --json 2>/dev/null)
    updates_status=$?
    # Older fwupd may not support --json on this subcommand at all.
    if ! echo "${updates_json}" | jq -e 'has("Devices")' >/dev/null 2>&1; then
        updates_json=""
    fi
fi

if [ -n "${updates_json}" ]; then
    pending=$(echo "${updates_json}" | jq -r '.Devices | length')
    if [ "${pending}" -gt 0 ]; then
        echo "${updates_json}" | jq -r '
            .Devices[]
            | "  \(.Name): \(.Version // "?") -> \(.Releases[0].Version // "?")"
              + (if ((.Flags // []) | index("needs-reboot")) then "  [reboot]" else "" end)
              + (if (.Releases[0].Summary // "") != "" then "\n      \(.Releases[0].Summary)" else "" end)
        '
    fi
else
    # No jq, or a fwupd too old for --json: fall back to the plain output and
    # trust the exit code.
    updates_text=$(fwupdmgr get-updates 2>&1)
    updates_status=$?
    echo "${updates_text}"
    pending=1
    # fwupd < 1.9 exited 0 even with nothing to do. Anchor at line start so
    # this does not match the "Devices with no available..." section heading.
    if echo "${updates_text}" | grep -qiE '^[[:space:]]*No updates available'; then
        pending=0
    fi
fi

case ${updates_status} in
    0|"${EXIT_NOTHING_TO_DO}"|"${EXIT_NOT_FOUND}") ;;
    *)
        echo >&2
        echo "firmware-update.sh: get-updates failed (exit ${updates_status})." >&2
        exit "${updates_status}"
        ;;
esac

# Report a reboot left over from an earlier update, regardless of whether
# there happen to be new updates today - this is state on the machine now,
# not something get-updates surfaces.
#
# Deliberately NOT using `fwupdmgr check-reboot-needed`: besides being
# interactive (it offers to reboot for you - only --json skips that
# prompt), it checks FWUPD_DEVICE_FLAG_NEEDS_REBOOT, which despite the
# name is a static per-device *capability* ("this device's update
# mechanism requires a reboot to apply"), not whether one is actually
# pending. On a typical UEFI/TPM laptop that flag is set on most
# updatable devices permanently, so the command reports "reboot needed"
# almost unconditionally - verified on this machine straight after a
# clean reboot with nothing pending.
#
# The real signal is per-device FwupdUpdateState: 4 = NeedsReboot, i.e.
# an update was applied and is waiting for a restart to take effect
# (2 = Success, already applied and done). Same field either output
# format uses - "Update State:" in plain text.
echo
echo "=== Reboot status ==="
if command -v jq >/dev/null 2>&1; then
    reboot_devices=$(fwupdmgr get-devices --json 2>/dev/null \
        | jq -r '[.Devices[] | select(.UpdateState == 4) | .Name]')
    reboot_count=$(echo "${reboot_devices}" | jq -r 'length' 2>/dev/null || echo 0)
    if [ "${reboot_count}" -gt 0 ] 2>/dev/null; then
        echo "Reboot needed to finish updating:"
        echo "${reboot_devices}" | jq -r '.[] | "  - \(.)"'
    else
        echo "No reboot needed."
    fi
else
    # No jq: grep the same "Update State: Needs reboot" field out of the
    # plain-text listing instead of naming which device it is.
    if fwupdmgr get-devices 2>/dev/null | grep -qE 'Update State:[[:space:]]*Needs reboot'; then
        echo "Reboot needed to finish a pending update."
    else
        echo "No reboot needed."
    fi
fi

if [ "${updates_status}" -eq "${EXIT_NOTHING_TO_DO}" ] || [ "${pending}" -eq 0 ]; then
    echo
    echo "No firmware updates available."
    exit 0
fi

if [ "${updates_status}" -eq "${EXIT_NOT_FOUND}" ]; then
    echo
    echo "No matching devices found."
    exit 0
fi

echo
echo "To apply these:"
echo "    fwupdmgr update"
echo
echo "Before you do:"
echo "  - plug in AC power (fwupd refuses BIOS updates on low battery)"
echo "  - a [reboot] payload flashes during the next boot; do not power off mid-flash"
echo "  - if you use TPM-backed LUKS unlock, have your recovery passphrase handy"
echo "    - a BIOS update changes the PCR values"
