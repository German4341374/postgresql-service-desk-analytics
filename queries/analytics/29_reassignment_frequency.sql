-- Incidents with multiple assignment records.
SELECT incident_id, incident_created_at, count(*) AS assignments
FROM incident_assignments
GROUP BY incident_id, incident_created_at
HAVING count(*) > 1
ORDER BY assignments DESC, incident_id
LIMIT 100;
