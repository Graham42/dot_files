#!/usr/bin/env bash

set -eo pipefail

if [ -z "$1" ]; then
  id=$(git rev-parse --abbrev-ref HEAD | cut -f2 -d/ | cut -f1 -d_)
  args=1
else \
  id=$1
  args=2
fi
git commit -em "$id

" "${@:${args}}"

