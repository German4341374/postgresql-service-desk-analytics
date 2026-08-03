-- Monthly resolution breach counts.
SELECT date_trunc('month', target_at)::date AS month,
       count(*) FILTER (WHERE breached) AS breached,
       count(*) AS measured
FROM sla_events
WHERE event_type = 'RESOLUTION'
GROUP BY month
ORDER BY month;
