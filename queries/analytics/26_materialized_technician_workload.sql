-- Precomputed technician workload dashboard.
SELECT * FROM mv_technician_workload
ORDER BY active_incidents DESC, technician_id
LIMIT 100;
