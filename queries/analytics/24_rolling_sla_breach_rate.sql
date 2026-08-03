-- Thirty-day rolling breach ratio.
WITH daily AS (
    SELECT target_at::date AS day,
           count(*) AS measured,
           count(*) FILTER (WHERE breached) AS breached
    FROM sla_events
    WHERE event_type = 'RESOLUTION'
    GROUP BY target_at::date
)
SELECT day,
       round(100.0 * sum(breached) OVER (ORDER BY day ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
             / nullif(sum(measured) OVER (ORDER BY day ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 0), 2) AS rolling_breach_percent
FROM daily
ORDER BY day;
