\timing on
SELECT pg_advisory_lock(hashtextextended('service-desk-materialized-refresh', 0));
REFRESH MATERIALIZED VIEW mv_monthly_sla_metrics;
REFRESH MATERIALIZED VIEW mv_technician_workload;
SELECT pg_advisory_unlock(hashtextextended('service-desk-materialized-refresh', 0));
\timing off
