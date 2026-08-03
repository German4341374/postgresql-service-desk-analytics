\timing on
SELECT pg_advisory_lock(hashtextextended('service-desk-index-build', 0));

CREATE INDEX IF NOT EXISTS idx_incidents_brin_created
    ON incidents USING brin (created_at) WITH (pages_per_range = 64);

CREATE INDEX IF NOT EXISTS idx_incidents_requester_created
    ON incidents (requester_id, created_at DESC) INCLUDE (status, priority);

CREATE INDEX IF NOT EXISTS idx_incidents_assignee_status
    ON incidents (assignee_id, status, created_at DESC) INCLUDE (priority, resolved_at);

CREATE INDEX IF NOT EXISTS idx_incidents_device_created
    ON incidents (device_id, created_at DESC) INCLUDE (status, priority);

CREATE INDEX IF NOT EXISTS idx_incidents_open_priority_due
    ON incidents (priority, sla_due_at, created_at)
    WHERE status IN ('OPEN', 'IN_PROGRESS', 'PENDING');

CREATE INDEX IF NOT EXISTS idx_incidents_search_gin
    ON incidents USING gin (search_document);

CREATE INDEX IF NOT EXISTS idx_incidents_service_status_created
    ON incidents (service_id, status, created_at DESC) INCLUDE (priority);

CREATE INDEX IF NOT EXISTS idx_comments_incident_created
    ON incident_comments (incident_id, incident_created_at, created_at);

CREATE INDEX IF NOT EXISTS idx_assignments_technician_active
    ON incident_assignments (technician_id, assigned_at DESC)
    WHERE unassigned_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_sla_breach_target
    ON sla_events (event_type, target_at, incident_id)
    WHERE breached;

CREATE INDEX IF NOT EXISTS idx_installations_software_version
    ON software_installations (software_id, installed_version, device_id);

ANALYZE;
SELECT pg_advisory_unlock(hashtextextended('service-desk-index-build', 0));
\timing off
