#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck source=common.sh
source "$(dirname "$0")/common.sh"

log_dir="${TMPDIR:-/tmp}/service-desk-deadlock-demo"
rm -rf "$log_dir"
mkdir -p "$log_dir"

set +e
psql_db >"$log_dir/session-a.log" 2>&1 <<'SQL' &
BEGIN;
SET LOCAL deadlock_timeout = '100ms';
UPDATE incidents SET updated_at = clock_timestamp() WHERE id = 1;
SELECT pg_sleep(1);
UPDATE incidents SET updated_at = clock_timestamp() WHERE id = 2;
COMMIT;
SQL
pid_a=$!

psql_db >"$log_dir/session-b.log" 2>&1 <<'SQL' &
BEGIN;
SET LOCAL deadlock_timeout = '100ms';
UPDATE incidents SET updated_at = clock_timestamp() WHERE id = 2;
SELECT pg_sleep(1);
UPDATE incidents SET updated_at = clock_timestamp() WHERE id = 1;
COMMIT;
SQL
pid_b=$!

wait "$pid_a"; status_a=$?
wait "$pid_b"; status_b=$?
set -e

if [[ "$status_a" -eq 0 && "$status_b" -eq 0 ]]; then
  printf 'Expected one transaction to be selected as a deadlock victim.\n' >&2
  exit 1
fi
if ! grep -qi 'deadlock detected' "$log_dir"/*.log; then
  printf 'A transaction failed, but PostgreSQL did not report the expected deadlock.\n' >&2
  cat "$log_dir"/*.log >&2
  exit 1
fi

ordered_transaction() {
  psql_db >/dev/null <<'SQL'
BEGIN;
SELECT id FROM incidents WHERE id IN (1, 2) ORDER BY id FOR UPDATE;
UPDATE incidents SET updated_at = clock_timestamp() WHERE id IN (1, 2);
COMMIT;
SQL
}

ordered_transaction & fixed_a=$!
ordered_transaction & fixed_b=$!
wait "$fixed_a"
wait "$fixed_b"

printf 'PASS: reproduced a deadlock, then avoided it with deterministic lock ordering.\n'
