-- Cumulative incident volume over time.
WITH daily AS (
    SELECT created_at::date AS day, count(*) AS incidents
    FROM incidents
    GROUP BY created_at::date
)
SELECT day, incidents, sum(incidents) OVER (ORDER BY day) AS running_total
FROM daily
ORDER BY day;
