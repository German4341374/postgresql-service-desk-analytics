-- Monthly incident volume by priority.
SELECT date_trunc('month', created_at)::date AS month, priority, count(*) AS incident_count
FROM incidents
GROUP BY month, priority
ORDER BY month, priority;
