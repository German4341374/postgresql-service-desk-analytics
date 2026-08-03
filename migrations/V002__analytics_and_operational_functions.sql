CREATE MATERIALIZED VIEW mv_monthly_sla_metrics AS
SELECT
    date_trunc('month', created_at)::date AS month,
    priority,
    count(*) AS incident_count,
    count(*) FILTER (WHERE resolved_at IS NOT NULL) AS resolved_count,
    count(*) FILTER (WHERE resolved_at > sla_due_at OR (resolved_at IS NULL AND sla_due_at < TIMESTAMPTZ '2026-01-01 00:00:00+00')) AS breached_count,
    percentile_cont(0.5) WITHIN GROUP (
        ORDER BY extract(epoch FROM (resolved_at - created_at)) / 60.0
    ) FILTER (WHERE resolved_at IS NOT NULL) AS median_resolution_minutes,
    percentile_cont(0.95) WITHIN GROUP (
        ORDER BY extract(epoch FROM (resolved_at - created_at)) / 60.0
    ) FILTER (WHERE resolved_at IS NOT NULL) AS p95_resolution_minutes
FROM incidents
GROUP BY 1, 2
WITH NO DATA;

CREATE UNIQUE INDEX mv_monthly_sla_metrics_key
    ON mv_monthly_sla_metrics (month, priority);

CREATE MATERIALIZED VIEW mv_technician_workload AS
SELECT
    t.id AS technician_id,
    t.display_name,
    count(i.*) FILTER (WHERE i.status IN ('OPEN', 'IN_PROGRESS', 'PENDING')) AS active_incidents,
    count(i.*) FILTER (WHERE i.status IN ('RESOLVED', 'CLOSED')) AS completed_incidents,
    avg(extract(epoch FROM (i.resolved_at - i.created_at)) / 60.0)
        FILTER (WHERE i.resolved_at IS NOT NULL) AS average_resolution_minutes
FROM technicians t
LEFT JOIN incidents i ON i.assignee_id = t.id
GROUP BY t.id, t.display_name
WITH NO DATA;

CREATE UNIQUE INDEX mv_technician_workload_key
    ON mv_technician_workload (technician_id);

CREATE OR REPLACE FUNCTION audit_incident_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
BEGIN
    INSERT INTO incident_audit_log (
        incident_id,
        incident_created_at,
        operation,
        changed_by,
        request_id,
        old_row,
        new_row
    ) VALUES (
        OLD.id,
        OLD.created_at,
        TG_OP,
        session_user,
        nullif(current_setting('app.request_id', true), ''),
        to_jsonb(OLD),
        CASE WHEN TG_OP = 'UPDATE' THEN to_jsonb(NEW) END
    );
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END
$function$;

CREATE TRIGGER incidents_audit_change
AFTER UPDATE OR DELETE ON incidents
FOR EACH ROW EXECUTE FUNCTION audit_incident_change();

CREATE OR REPLACE PROCEDURE retain_incidents(
    p_cutoff timestamptz,
    p_dry_run boolean DEFAULT true
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    candidates bigint;
    removed bigint := 0;
BEGIN
    PERFORM pg_advisory_xact_lock(hashtextextended('incident-retention', 0));

    SELECT count(*) INTO candidates
    FROM incidents
    WHERE created_at < p_cutoff;

    IF NOT p_dry_run THEN
        DELETE FROM incidents WHERE created_at < p_cutoff;
        GET DIAGNOSTICS removed = ROW_COUNT;
    END IF;

    INSERT INTO retention_runs (
        cutoff,
        dry_run,
        candidate_rows,
        deleted_rows,
        executed_by
    ) VALUES (
        p_cutoff,
        p_dry_run,
        candidates,
        removed,
        session_user
    );
END
$procedure$;

CREATE OR REPLACE FUNCTION safe_upsert_software_installation(
    p_device_id bigint,
    p_software_id integer,
    p_version text,
    p_observed_at timestamptz
)
RETURNS bigint
LANGUAGE sql
AS $function$
    INSERT INTO software_installations (
        id,
        device_id,
        software_id,
        installed_version,
        installed_at,
        last_seen_at
    ) VALUES (
        (p_device_id * 1000) + p_software_id,
        p_device_id,
        p_software_id,
        p_version,
        p_observed_at,
        p_observed_at
    )
    ON CONFLICT (device_id, software_id) DO UPDATE
    SET installed_version = EXCLUDED.installed_version,
        last_seen_at = GREATEST(software_installations.last_seen_at, EXCLUDED.last_seen_at),
        updated_at = clock_timestamp()
    WHERE EXCLUDED.last_seen_at >= software_installations.last_seen_at
    RETURNING id;
$function$;
