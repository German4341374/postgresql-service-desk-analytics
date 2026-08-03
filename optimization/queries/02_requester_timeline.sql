EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT)
SELECT id, title, priority, status, created_at
FROM incidents
WHERE requester_id = 4242
ORDER BY created_at DESC
LIMIT 100;
