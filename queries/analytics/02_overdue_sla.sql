-- Unresolved incidents whose deterministic SLA deadline has passed.
SELECT priority, count(*) AS overdue_count
FROM incidents
WHERE status IN ('OPEN', 'IN_PROGRESS', 'PENDING')
  AND sla_due_at < TIMESTAMPTZ '2026-01-01 00:00:00+00'
GROUP BY priority
ORDER BY priority;
