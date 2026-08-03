#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck source=common.sh
source "$(dirname "$0")/common.sh"

RESULTS_DIR="${RESULTS_DIR:-optimization/results/generated}"
BASELINE_DIR="$RESULTS_DIR/baseline"
OPTIMIZED_DIR="$RESULTS_DIR/optimized"
rm -rf "$RESULTS_DIR"
mkdir -p "$BASELINE_DIR" "$OPTIMIZED_DIR"

capture_plan() {
  local query_file="$1"
  local destination="$2"
  psql_db --file="/workspace/$query_file" >/dev/null
  psql_db --file="/workspace/$query_file" >"$destination"
}

{
  printf 'captured_at_utc=%s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  printf 'git_commit=%s\n' "${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || printf unknown)}"
  printf 'postgres_version='; psql_db --tuples-only --no-align --command='SHOW server_version;'
  printf 'database_size='; psql_db --tuples-only --no-align --command="SELECT pg_size_pretty(pg_database_size(current_database()));"
  psql_db --tuples-only --no-align --field-separator='=' --command="
    SELECT 'users', count(*) FROM service_desk_users
    UNION ALL SELECT 'devices', count(*) FROM devices
    UNION ALL SELECT 'incidents', count(*) FROM incidents
    UNION ALL SELECT 'comments', count(*) FROM incident_comments
    UNION ALL SELECT 'assignments', count(*) FROM incident_assignments
    UNION ALL SELECT 'sla_events', count(*) FROM sla_events
    UNION ALL SELECT 'software_installations', count(*) FROM software_installations
    ORDER BY 1;"
} >"$RESULTS_DIR/metadata.txt"

psql_db --file=/workspace/optimization/drop.sql >"$RESULTS_DIR/drop-indexes.log"

for query_file in optimization/queries/*.sql; do
  name="$(basename "$query_file" .sql)"
  printf 'Capturing baseline plan: %s\n' "$name"
  capture_plan "$query_file" "$BASELINE_DIR/$name.txt"
done

psql_db --file=/workspace/optimization/apply.sql >"$RESULTS_DIR/apply-indexes.log"

for query_file in optimization/queries/*.sql; do
  name="$(basename "$query_file" .sql)"
  printf 'Capturing optimized plan: %s\n' "$name"
  capture_plan "$query_file" "$OPTIMIZED_DIR/$name.txt"
done

printf 'case,baseline_execution_ms,optimized_execution_ms\n' >"$RESULTS_DIR/summary.csv"
for baseline in "$BASELINE_DIR"/*.txt; do
  name="$(basename "$baseline" .txt)"
  optimized="$OPTIMIZED_DIR/$name.txt"
  baseline_ms="$(grep -m1 'Execution Time:' "$baseline" | awk '{print $(NF-1)}')"
  optimized_ms="$(grep -m1 'Execution Time:' "$optimized" | awk '{print $(NF-1)}')"
  printf '%s,%s,%s\n' "$name" "$baseline_ms" "$optimized_ms" >>"$RESULTS_DIR/summary.csv"
done

psql_db --tuples-only --no-align --field-separator=',' --command="
  SELECT relname, pg_relation_size(oid), pg_size_pretty(pg_relation_size(oid))
  FROM pg_class
  WHERE relname LIKE 'idx_%'
  ORDER BY pg_relation_size(oid) DESC, relname;" >"$RESULTS_DIR/index-sizes.csv"

printf 'Benchmark artifacts written to %s\n' "$RESULTS_DIR"
