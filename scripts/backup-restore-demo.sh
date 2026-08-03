#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck source=common.sh
source "$(dirname "$0")/common.sh"

backup_file="$(bash scripts/backup.sh)"
restore_database="${POSTGRES_DB}_restore_test"
RESTORE_DATABASE="$restore_database" bash scripts/restore.sh "$backup_file"

source_count="$(psql_db --tuples-only --no-align --command='SELECT count(*) FROM incidents;')"
restored_count="$(compose exec -T -e "PGPASSWORD=$POSTGRES_PASSWORD" database \
  psql -X --set=ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$restore_database" \
  --tuples-only --no-align --command='SELECT count(*) FROM incidents;')"

if [[ "$source_count" != "$restored_count" ]]; then
  printf 'Restore verification failed: source=%s restored=%s\n' "$source_count" "$restored_count" >&2
  exit 1
fi

psql_admin --command="DROP DATABASE \"$restore_database\" WITH (FORCE);"
rm -f "$backup_file"
printf 'PASS: custom-format backup restored %s incident rows.\n' "$restored_count"
