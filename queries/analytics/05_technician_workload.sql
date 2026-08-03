-- Current active workload per technician.
SELECT t.id, t.display_name, count(i.*) AS active_incidents
FROM technicians t
JOIN incidents i ON i.assignee_id = t.id
WHERE i.status IN ('OPEN', 'IN_PROGRESS', 'PENDING')
GROUP BY t.id, t.display_name
ORDER BY active_incidents DESC, t.id
LIMIT 50;
