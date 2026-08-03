-- Month-over-month volume change with LAG.
WITH monthly AS (
    SELECT date_trunc('month', created_at)::date AS month, count(*) AS incidents
    FROM incidents GROUP BY month
)
SELECT month, incidents,
       incidents - lag(incidents) OVER (ORDER BY month) AS absolute_change,
       round(100.0 * (incidents - lag(incidents) OVER (ORDER BY month))
             / nullif(lag(incidents) OVER (ORDER BY month), 0), 2) AS percent_change
FROM monthly
ORDER BY month;
