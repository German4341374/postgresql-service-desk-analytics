\set ON_ERROR_STOP on

DO $test$
DECLARE
    manifest dataset_manifest%ROWTYPE;
    actual bigint;
BEGIN
    SELECT * INTO STRICT manifest FROM dataset_manifest WHERE singleton;

    SELECT count(*) INTO actual FROM service_desk_users;
    IF actual <> manifest.user_count THEN
        RAISE EXCEPTION 'User count mismatch: expected %, got %', manifest.user_count, actual;
    END IF;

    SELECT count(*) INTO actual FROM devices;
    IF actual <> manifest.device_count THEN
        RAISE EXCEPTION 'Device count mismatch: expected %, got %', manifest.device_count, actual;
    END IF;

    SELECT count(*) INTO actual FROM incidents;
    IF actual <> manifest.incident_count THEN
        RAISE EXCEPTION 'Incident count mismatch: expected %, got %', manifest.incident_count, actual;
    END IF;

    SELECT count(*) INTO actual FROM incident_comments;
    IF actual <> manifest.incident_count + floor(manifest.incident_count / 4.0) THEN
        RAISE EXCEPTION 'Comment count mismatch: got %', actual;
    END IF;

    SELECT count(*) INTO actual FROM incident_assignments;
    IF actual <> manifest.incident_count + floor(manifest.incident_count / 9.0) THEN
        RAISE EXCEPTION 'Assignment count mismatch: got %', actual;
    END IF;

    SELECT count(*) INTO actual FROM sla_events;
    IF actual <> manifest.incident_count * 2 THEN
        RAISE EXCEPTION 'SLA event count mismatch: got %', actual;
    END IF;

    SELECT count(*) INTO actual FROM software_installations;
    IF actual <> manifest.device_count * 3 THEN
        RAISE EXCEPTION 'Installation count mismatch: got %', actual;
    END IF;

    SELECT count(*) INTO actual
    FROM pg_inherits inheritance
    JOIN pg_class parent ON parent.oid = inheritance.inhparent
    WHERE parent.relname = 'incidents';
    IF actual <> 37 THEN
        RAISE EXCEPTION 'Expected 36 monthly partitions and one default partition, got %', actual;
    END IF;

    SELECT count(*) INTO actual FROM incidents_default;
    IF actual <> 0 THEN
        RAISE EXCEPTION 'Default incident partition must remain empty, got % rows', actual;
    END IF;

    SELECT count(*) INTO actual
    FROM incidents
    WHERE search_document @@ websearch_to_tsquery('english', 'VPN timeout');
    IF actual = 0 THEN
        RAISE EXCEPTION 'Full-text search returned no deterministic matches';
    END IF;

    SELECT count(*) INTO actual FROM mv_monthly_sla_metrics;
    IF actual = 0 THEN
        RAISE EXCEPTION 'Monthly SLA materialized view is empty';
    END IF;

    SELECT count(*) INTO actual FROM pg_indexes
    WHERE indexname IN (
        'idx_incidents_brin_created',
        'idx_incidents_search_gin',
        'idx_incidents_requester_created'
    );
    IF actual <> 3 THEN
        RAISE EXCEPTION 'Required BRIN, GIN, and B-tree indexes are missing';
    END IF;
END
$test$;

BEGIN;
SET LOCAL app.request_id = 'smoke-audit-request';
UPDATE incidents SET updated_at = clock_timestamp() WHERE id = 1;
DO $audit_test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM incident_audit_log
        WHERE incident_id = 1 AND request_id = 'smoke-audit-request'
    ) THEN
        RAISE EXCEPTION 'Incident audit trigger did not capture the update';
    END IF;
END
$audit_test$;
ROLLBACK;

BEGIN;
SELECT safe_upsert_software_installation(1, 1, '9.9.9-smoke', TIMESTAMPTZ '2026-01-02');
SELECT safe_upsert_software_installation(1, 1, '1.0.0-stale', TIMESTAMPTZ '2025-01-01');
DO $upsert_test$
BEGIN
    IF (SELECT installed_version FROM software_installations WHERE device_id = 1 AND software_id = 1) <> '9.9.9-smoke' THEN
        RAISE EXCEPTION 'Stale upsert overwrote a newer observation';
    END IF;
END
$upsert_test$;
ROLLBACK;

SET ROLE sd_department_analyst;
SET app.current_department_id = '1';
DO $rls_test$
BEGIN
    IF EXISTS (SELECT 1 FROM department_notes WHERE department_id <> 1) THEN
        RAISE EXCEPTION 'RLS exposed another department';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM department_notes WHERE department_id = 1) THEN
        RAISE EXCEPTION 'RLS hid the selected department';
    END IF;
END
$rls_test$;
RESET ROLE;

CALL retain_incidents(TIMESTAMPTZ '2023-02-01 00:00:00+00', true);
DO $retention_test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM retention_runs
        WHERE dry_run AND deleted_rows = 0 AND candidate_rows > 0
    ) THEN
        RAISE EXCEPTION 'Retention dry run did not record candidates safely';
    END IF;
END
$retention_test$;

SELECT 'PASS: schema, data, search, indexes, materialized views, audit, upsert, RLS, and retention' AS result;
