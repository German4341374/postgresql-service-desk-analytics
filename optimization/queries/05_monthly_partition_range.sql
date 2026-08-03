EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT)
SELECT priority, status, count(*) AS incident_count
FROM incidents
WHERE created_at >= TIMESTAMPTZ '2025-07-01 00:00:00+00'
  AND created_at < TIMESTAMPTZ '2025-08-01 00:00:00+00'
GROUP BY priority, status
ORDER BY priority, status;
