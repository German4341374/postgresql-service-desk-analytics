-- Detect incidents lacking communication evidence.
SELECT count(*) AS incidents_without_comments
FROM incidents i
WHERE NOT EXISTS (
    SELECT 1 FROM incident_comments c
    WHERE c.incident_id = i.id AND c.incident_created_at = i.created_at
);
