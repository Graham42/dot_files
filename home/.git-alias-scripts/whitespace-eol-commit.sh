#!/usr/bin/env bash
git add -A
git diff --cached --ignore-space-at-eol | git apply --cached --reverse
git commit -m "Format code"
