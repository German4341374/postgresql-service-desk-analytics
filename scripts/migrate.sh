#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck source=common.sh
source "$(dirname "$0")/common.sh"

{
  printf '%s\n' '\set ON_ERROR_STOP on'
  printf '%s\n' "CREATE TABLE IF NOT EXISTS schema_migrations (version text PRIMARY KEY, checksum text NOT NULL, applied_at timestamptz NOT NULL DEFAULT clock_timestamp());"
  printf '%s\n' "SELECT pg_advisory_lock(hashtextextended('postgresql-service-desk-analytics-migrations', 0));"

  for migration in migrations/V*.sql; do
    version="$(basename "$migration" .sql)"
    checksum="$(sha256sum "$migration" | awk '{print $1}')"
    container_path="/workspace/$migration"
    printf '\\echo Checking %s\n' "$version"
    printf "SELECT NOT EXISTS (SELECT 1 FROM schema_migrations WHERE version = '%s') AS should_apply \\gset\n" "$version"
    printf '%s\n' '\if :should_apply'
    printf '%s\n' 'BEGIN;'
    printf '\\ir %s\n' "$container_path"
    printf "INSERT INTO schema_migrations(version, checksum) VALUES ('%s', '%s');\n" "$version" "$checksum"
    printf '%s\n' 'COMMIT;'
    printf '\\echo Applied %s\n' "$version"
    printf '%s\n' '\else'
    printf "DO \$check\$ BEGIN IF NOT EXISTS (SELECT 1 FROM schema_migrations WHERE version = '%s' AND checksum = '%s') THEN RAISE EXCEPTION 'Checksum mismatch for applied migration %s'; END IF; END \$check\$;\n" "$version" "$checksum" "$version"
    printf '\\echo Already current: %s\n' "$version"
    printf '%s\n' '\endif'
  done

  printf '%s\n' "SELECT pg_advisory_unlock(hashtextextended('postgresql-service-desk-analytics-migrations', 0));"
} | psql_db
