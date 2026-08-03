-- Deterministic backlog aging as of the reporting timestamp.
SELECT CASE
           WHEN TIMESTAMPTZ '2026-01-01' - created_at < INTERVAL '1 day' THEN '<1 day'
           WHEN TIMESTAMPTZ '2026-01-01' - created_at < INTERVAL '7 days' THEN '1-7 days'
           WHEN TIMESTAMPTZ '2026-01-01' - created_at < INTERVAL '30 days' THEN '7-30 days'
           ELSE '30+ days'
       END AS age_bucket,
       count(*) AS incidents
FROM incidents
WHERE status IN ('OPEN', 'IN_PROGRESS', 'PENDING')
GROUP BY age_bucket
ORDER BY min(TIMESTAMPTZ '2026-01-01' - created_at);
