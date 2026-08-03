-- Technician position within completed-incident distribution.
WITH completed AS (
    SELECT assignee_id, count(*) AS resolved_count
    FROM incidents
    WHERE status IN ('RESOLVED', 'CLOSED')
    GROUP BY assignee_id
)
SELECT assignee_id, resolved_count,
       round((percent_rank() OVER (ORDER BY resolved_count))::numeric, 4) AS percent_rank
FROM completed
ORDER BY resolved_count DESC, assignee_id
LIMIT 100;
