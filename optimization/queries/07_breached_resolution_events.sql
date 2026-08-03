EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT)
SELECT incident_id, target_at, occurred_at
FROM sla_events
WHERE event_type = 'RESOLUTION'
  AND breached
  AND target_at >= TIMESTAMPTZ '2025-10-01 00:00:00+00'
  AND target_at < TIMESTAMPTZ '2025-11-01 00:00:00+00'
ORDER BY target_at
LIMIT 500;
