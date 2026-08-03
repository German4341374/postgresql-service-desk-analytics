-- Average resolution time in minutes by priority.
SELECT priority,
       round(avg(extract(epoch FROM (resolved_at - created_at)) / 60.0), 2) AS average_minutes
FROM incidents
WHERE resolved_at IS NOT NULL
GROUP BY priority
ORDER BY priority;
