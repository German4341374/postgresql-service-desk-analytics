#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck source=common.sh
source "$(dirname "$0")/common.sh"

backup_file="${1:?Usage: scripts/restore.sh path/to/backup.dump}"
restore_database="${RESTORE_DATABASE:-${POSTGRES_DB}_restored}"
require_sql_identifier "$restore_database"

if [[ ! -s "$backup_file" ]]; then
  printf 'Backup file is missing or empty: %s\n' "$backup_file" >&2
  exit 1
fi

psql_admin --command="DROP DATABASE IF EXISTS \"$restore_database\" WITH (FORCE);"
psql_admin --command="CREATE DATABASE \"$restore_database\";"

compose exec -T -e "PGPASSWORD=$POSTGRES_PASSWORD" database \
  pg_restore --username "$POSTGRES_USER" --dbname "$restore_database" \
  --no-owner --no-privileges --exit-on-error <"$backup_file"

printf 'Restored %s into database %s.\n' "$backup_file" "$restore_database"
