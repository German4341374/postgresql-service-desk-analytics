-- Seven-day moving average using a window frame.
WITH daily AS (
    SELECT created_at::date AS day, count(*) AS incidents
    FROM incidents
    GROUP BY created_at::date
)
SELECT day, incidents,
       round(avg(incidents) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_average_7d
FROM daily
ORDER BY day;
