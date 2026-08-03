#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck source=common.sh
source "$(dirname "$0")/common.sh"

mkdir -p backups
backup_file="backups/${POSTGRES_DB}_$(date -u +'%Y%m%dT%H%M%SZ').dump"
compose exec -T -e "PGPASSWORD=$POSTGRES_PASSWORD" database \
  pg_dump --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  --format=custom --compress=zstd:6 --no-owner --no-privileges >"$backup_file"

if [[ ! -s "$backup_file" ]]; then
  printf 'Backup was not created or is empty.\n' >&2
  exit 1
fi
printf '%s\n' "$backup_file"
