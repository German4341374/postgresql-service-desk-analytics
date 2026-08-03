EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT)
SELECT id, priority, status, created_at
FROM incidents
WHERE service_id = 10
  AND status IN ('OPEN', 'IN_PROGRESS', 'PENDING')
  AND priority = 'P1'
ORDER BY created_at DESC
LIMIT 200;
