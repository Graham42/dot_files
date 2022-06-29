#!/usr/bin/env bash
BASE=$1
LOCAL=$2
REMOTE=$3
MERGED=$4

set -x

if grep -i -q microsoft /proc/version; then
  p4merge.exe -le unix -C utf8 "$BASE" "$LOCAL" "$REMOTE" "$MERGED"
else
  p4merge -le unix "$BASE" "$LOCAL" "$REMOTE" "$MERGED"
fi
