-- Service MTTR compared with the portfolio average.
WITH metrics AS (
    SELECT service_id,
           avg(extract(epoch FROM resolved_at - created_at) / 60.0) AS mttr
    FROM incidents
    WHERE resolved_at IS NOT NULL
    GROUP BY service_id
)
SELECT service_id, round(mttr, 2) AS mttr_minutes,
       round(avg(mttr) OVER (), 2) AS portfolio_average,
       round(mttr - avg(mttr) OVER (), 2) AS variance_from_average
FROM metrics
ORDER BY variance_from_average DESC;
