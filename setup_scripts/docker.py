#!/usr/bin/env python3
# Ensures ~/.docker/config.json has detachKeys set to ctrl-q,ctrl-q.
# This overrides the default ctrl-p,ctrl-q which conflicts with shell history navigation.

import json
import os
from pathlib import Path

config_path = Path.home() / ".docker" / "config.json"
config_path.parent.mkdir(exist_ok=True)

if config_path.exists():
    config = json.loads(config_path.read_text())
else:
    config = {}

if config.get("detachKeys") == "ctrl-q,ctrl-q":
    print(f"{config_path} already has detachKeys set, nothing to do")
else:
    config["detachKeys"] = "ctrl-q,ctrl-q"
    config_path.write_text(json.dumps(config, indent="\t") + "\n")
    print(f"Updated {config_path}")
