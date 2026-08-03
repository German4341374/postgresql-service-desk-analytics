-- Department backlog weighted by priority.
SELECT d.id, d.name,
       sum(CASE i.priority WHEN 'P1' THEN 8 WHEN 'P2' THEN 4 WHEN 'P3' THEN 2 ELSE 1 END) AS risk_score,
       count(*) AS active_incidents
FROM departments d
JOIN service_desk_users u ON u.department_id = d.id
JOIN incidents i ON i.requester_id = u.id
WHERE i.status IN ('OPEN', 'IN_PROGRESS', 'PENDING')
GROUP BY d.id, d.name
ORDER BY risk_score DESC, d.id;
