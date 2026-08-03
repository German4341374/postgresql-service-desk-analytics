-- Rank technicians without losing ties.
WITH workload AS (
    SELECT assignee_id, count(*) AS active_count
    FROM incidents
    WHERE status IN ('OPEN', 'IN_PROGRESS', 'PENDING')
    GROUP BY assignee_id
)
SELECT assignee_id, active_count,
       dense_rank() OVER (ORDER BY active_count DESC) AS workload_rank
FROM workload
ORDER BY workload_rank, assignee_id
LIMIT 50;
