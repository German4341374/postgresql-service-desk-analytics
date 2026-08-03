EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT)
SELECT id, title, priority, status, created_at
FROM incidents
WHERE device_id = 12345
ORDER BY created_at DESC
LIMIT 100;
