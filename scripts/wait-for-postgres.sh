#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck source=common.sh
source "$(dirname "$0")/common.sh"

for attempt in {1..60}; do
  if compose exec -T database pg_isready --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" >/dev/null 2>&1; then
    printf 'PostgreSQL is ready after %d attempt(s).\n' "$attempt"
    exit 0
  fi
  sleep 2
done

printf 'PostgreSQL did not become ready in time.\n' >&2
compose logs --no-color database >&2
exit 1
