EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT)
SELECT id, priority, status, sla_due_at
FROM incidents
WHERE status IN ('OPEN', 'IN_PROGRESS', 'PENDING')
  AND priority IN ('P1', 'P2')
  AND sla_due_at < TIMESTAMPTZ '2026-01-01 00:00:00+00'
ORDER BY sla_due_at
LIMIT 200;
