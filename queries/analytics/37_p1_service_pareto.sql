-- Cumulative share of P1 incidents by service.
WITH volumes AS (
    SELECT service_id, count(*) AS p1_count
    FROM incidents WHERE priority = 'P1' GROUP BY service_id
)
SELECT service_id, p1_count,
       round(100.0 * sum(p1_count) OVER (ORDER BY p1_count DESC, service_id)
             / sum(p1_count) OVER (), 2) AS cumulative_percent
FROM volumes
ORDER BY p1_count DESC, service_id;
