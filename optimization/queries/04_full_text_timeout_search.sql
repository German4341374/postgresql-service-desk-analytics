EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT)
SELECT id, title, priority, created_at
FROM incidents
WHERE search_document @@ websearch_to_tsquery('english', 'VPN timeout')
ORDER BY created_at DESC
LIMIT 100;
