-- First-response distribution in minutes.
SELECT priority,
       round(avg(extract(epoch FROM first_response_at - created_at) / 60.0), 2) AS average_minutes,
       percentile_cont(0.95) WITHIN GROUP (ORDER BY extract(epoch FROM first_response_at - created_at) / 60.0) AS p95_minutes
FROM incidents
WHERE first_response_at IS NOT NULL
GROUP BY priority
ORDER BY priority;
