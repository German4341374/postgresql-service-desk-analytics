EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT)
SELECT priority, count(*) AS incident_count
FROM incidents
WHERE assignee_id = 777
  AND status IN ('OPEN', 'IN_PROGRESS', 'PENDING')
GROUP BY priority
ORDER BY priority;
