#!/usr/bin/env python3
# Sorts all object keys in a JSON file (recursively) and rewrites it in place.
# Makes diffs to JSON config files easier to see and reason about, since keys
# always land in the same order regardless of the order they were added in.
#
# Usage: helpers/sort_json_keys.py path/to/file.json [more/files.json ...]

import json
import subprocess
import sys
from pathlib import Path


def sort_json_file(path: Path) -> bool:
    """Sorts keys in-place. Returns True if the file's contents changed."""
    original = path.read_text()
    data = json.loads(original)
    # sort_keys sorts dict keys at every nesting level; list order is left
    # untouched since list order can be semantically meaningful.
    sorted_text = json.dumps(data, indent=2, sort_keys=True) + "\n"

    if sorted_text == original:
        return False

    path.write_text(sorted_text)
    return True


def main(argv: list[str]) -> int:
    if not argv:
        print("usage: sort_json_keys.py <file.json> [file.json ...]", file=sys.stderr)
        return 1

    exit_code = 0
    sorted_paths = []
    for arg in argv:
        path = Path(arg)
        try:
            changed = sort_json_file(path)
        except (json.JSONDecodeError, OSError) as e:
            print(f"{path}: {e}", file=sys.stderr)
            exit_code = 1
            continue

        print(f"{path}: {'sorted' if changed else 'already sorted'}")
        sorted_paths.append(str(path))

    # json.dumps' formatting is close but not identical to this project's
    # style (e.g. trailing newline quirks); run it through prettier so the
    # end result matches what everything else is formatted with.
    if sorted_paths:
        subprocess.run(["bunx", "prettier", "--write", *sorted_paths], check=True)

    return exit_code


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
