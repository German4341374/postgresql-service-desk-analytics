#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck source=common.sh
source "$(dirname "$0")/common.sh"

count=0
for query in queries/analytics/*.sql; do
  printf 'Checking analytical query: %s\n' "$(basename "$query")"
  psql_db --file="/workspace/$query" >/dev/null
  count=$((count + 1))
done

if [[ "$count" -lt 40 ]]; then
  printf 'Expected at least 40 analytical queries, found %d.\n' "$count" >&2
  exit 1
fi
printf 'PASS: executed %d analytical queries.\n' "$count"
