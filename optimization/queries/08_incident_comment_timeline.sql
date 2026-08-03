EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT)
SELECT author_kind, author_id, body, created_at
FROM incident_comments
WHERE incident_id = 500000
  AND incident_created_at >= TIMESTAMPTZ '2023-01-01 00:00:00+00'
ORDER BY created_at;
