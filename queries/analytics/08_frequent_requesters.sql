-- Requesters generating the most incidents.
SELECT u.id, u.full_name, u.department_id, count(i.*) AS incident_count
FROM service_desk_users u
JOIN incidents i ON i.requester_id = u.id
GROUP BY u.id, u.full_name, u.department_id
ORDER BY incident_count DESC, u.id
LIMIT 100;
