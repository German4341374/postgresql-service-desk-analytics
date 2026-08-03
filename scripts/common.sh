#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

POSTGRES_DB="${POSTGRES_DB:-service_desk_analytics}"
POSTGRES_USER="${POSTGRES_USER:-service_desk}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-local-development-only-change-me}"
export POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD

compose() {
  docker compose "$@"
}

psql_db() {
  compose exec -T \
    -e "PGPASSWORD=$POSTGRES_PASSWORD" \
    database psql -X --set=ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" "$@"
}

psql_admin() {
  compose exec -T \
    -e "PGPASSWORD=$POSTGRES_PASSWORD" \
    database psql -X --set=ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres "$@"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Required command is unavailable: %s\n' "$1" >&2
    exit 1
  fi
}

require_sql_identifier() {
  if [[ ! "$1" =~ ^[a-z_][a-z0-9_]*$ ]]; then
    printf 'Unsafe PostgreSQL identifier: %s\n' "$1" >&2
    exit 1
  fi
}

require_command docker
require_sql_identifier "$POSTGRES_DB"
require_sql_identifier "$POSTGRES_USER"
