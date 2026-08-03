CALL retain_incidents(TIMESTAMPTZ '2023-02-01 00:00:00+00', true);
SELECT cutoff, dry_run, candidate_rows, deleted_rows, executed_by, executed_at
FROM retention_runs
ORDER BY id DESC
LIMIT 1;
