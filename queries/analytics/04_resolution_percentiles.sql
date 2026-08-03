-- Median, p90, and p95 resolution minutes.
SELECT priority,
       percentile_cont(0.50) WITHIN GROUP (ORDER BY extract(epoch FROM resolved_at - created_at) / 60.0) AS p50,
       percentile_cont(0.90) WITHIN GROUP (ORDER BY extract(epoch FROM resolved_at - created_at) / 60.0) AS p90,
       percentile_cont(0.95) WITHIN GROUP (ORDER BY extract(epoch FROM resolved_at - created_at) / 60.0) AS p95
FROM incidents
WHERE resolved_at IS NOT NULL
GROUP BY priority
ORDER BY priority;
