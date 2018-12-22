#!/usr/bin/env bash
# Requires the environment variable JIRA_URL to be set

set -eo pipefail

if [ -z "$JIRA_URL" ]; then
  echo "ERROR: env var 'JIRA_URL' is not set"
  exit 1
fi

if [ -z "$1" ]; then
  id=$(git rev-parse --abbrev-ref HEAD | cut -f2 -d/ | cut -f1 -d_)
  args=1
else \
  id=$1
  args=2
fi
git commit -em "$id

[$id]($JIRA_URL/browse/$id)" "${@:${args}}"

