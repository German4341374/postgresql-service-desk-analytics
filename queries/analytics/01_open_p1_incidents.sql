-- Open P1 incidents requiring immediate attention.
SELECT id, title, status, assignee_id, created_at, sla_due_at
FROM incidents
WHERE priority = 'P1' AND status IN ('OPEN', 'IN_PROGRESS', 'PENDING')
ORDER BY created_at
LIMIT 100;
