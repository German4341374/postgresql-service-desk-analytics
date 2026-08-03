-- Backlog by service criticality.
SELECT s.criticality, i.priority, count(*) AS active_incidents
FROM services s
JOIN incidents i ON i.service_id = s.id
WHERE i.status IN ('OPEN', 'IN_PROGRESS', 'PENDING')
GROUP BY s.criticality, i.priority
ORDER BY s.criticality DESC, i.priority;
