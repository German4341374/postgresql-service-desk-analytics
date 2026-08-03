-- Compare resolution time with comment volume.
WITH comment_counts AS (
    SELECT incident_id, incident_created_at, count(*) AS comments
    FROM incident_comments
    GROUP BY incident_id, incident_created_at
)
SELECT c.comments,
       count(*) AS incidents,
       round(avg(extract(epoch FROM i.resolved_at - i.created_at) / 60.0), 2) AS average_resolution_minutes
FROM comment_counts c
JOIN incidents i ON i.id = c.incident_id AND i.created_at = c.incident_created_at
WHERE i.resolved_at IS NOT NULL
GROUP BY c.comments
ORDER BY c.comments;
