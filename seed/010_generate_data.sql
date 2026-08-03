\timing on
BEGIN;
SET LOCAL synchronous_commit = off;
SELECT pg_advisory_xact_lock(hashtextextended('service-desk-deterministic-seed', 0));

TRUNCATE TABLE
    incident_audit_log,
    retention_runs,
    sla_events,
    incident_assignments,
    incident_comments,
    software_installations,
    incidents,
    devices,
    technicians,
    service_desk_users,
    dataset_manifest
RESTART IDENTITY CASCADE;

INSERT INTO service_desk_users (
    id,
    department_id,
    full_name,
    email,
    location,
    active,
    created_at,
    updated_at
)
SELECT
    number,
    ((number - 1) % 100) + 1,
    format('Demo User %s', lpad(number::text, 6, '0')),
    format('user.%s@example.invalid', lpad(number::text, 6, '0')),
    format('Office %s', lpad((((number - 1) % 40) + 1)::text, 2, '0')),
    number % 97 <> 0,
    TIMESTAMPTZ '2022-01-01 00:00:00+00' + ((number - 1) % 365) * INTERVAL '1 day',
    TIMESTAMPTZ '2025-12-31 00:00:00+00'
FROM generate_series(1, :user_count) AS series(number);

INSERT INTO technicians (
    id,
    department_id,
    display_name,
    skill_tier,
    active,
    created_at,
    updated_at
)
SELECT
    number,
    ((number * 7 - 1) % 100) + 1,
    format('Support Engineer %s', lpad(number::text, 5, '0')),
    ((number - 1) % 4) + 1,
    number % 89 <> 0,
    TIMESTAMPTZ '2022-01-01 00:00:00+00' + ((number - 1) % 365) * INTERVAL '1 day',
    TIMESTAMPTZ '2025-12-31 00:00:00+00'
FROM generate_series(1, :technician_count) AS series(number);

INSERT INTO devices (
    id,
    assigned_user_id,
    asset_tag,
    hostname,
    device_type,
    operating_system,
    status,
    purchased_at,
    warranty_until,
    created_at,
    updated_at
)
SELECT
    number,
    ((number - 1) % :user_count) + 1,
    format('AST-%s', lpad(number::text, 8, '0')),
    format('device-%s.example.invalid', lpad(number::text, 8, '0')),
    (ARRAY['LAPTOP', 'DESKTOP', 'MOBILE', 'THIN_CLIENT'])[((number - 1) % 4) + 1],
    (ARRAY['Windows 11', 'Ubuntu 24.04', 'macOS 15', 'Android 16'])[((number - 1) % 4) + 1],
    CASE
        WHEN number % 101 = 0 THEN 'RETIRED'::device_status
        WHEN number % 37 = 0 THEN 'REPAIR'::device_status
        ELSE 'ACTIVE'::device_status
    END,
    DATE '2020-01-01' + ((number - 1) % 1825),
    DATE '2023-01-01' + ((number - 1) % 1825),
    TIMESTAMPTZ '2022-01-01 00:00:00+00' + ((number - 1) % 365) * INTERVAL '1 day',
    TIMESTAMPTZ '2025-12-31 00:00:00+00'
FROM generate_series(1, :device_count) AS series(number);

WITH generated AS (
    SELECT
        number,
        TIMESTAMPTZ '2023-01-01 00:00:00+00'
            + ((number * 17) % 1095) * INTERVAL '1 day'
            + ((number::bigint * 7919) % 86400) * INTERVAL '1 second' AS opened_at,
        CASE
            WHEN number % 100 = 0 THEN 'P1'::incident_priority
            WHEN number % 10 = 0 THEN 'P2'::incident_priority
            WHEN number % 3 = 0 THEN 'P3'::incident_priority
            ELSE 'P4'::incident_priority
        END AS generated_priority,
        CASE
            WHEN number % 13 = 0 THEN 'OPEN'::incident_status
            WHEN number % 11 = 0 THEN 'IN_PROGRESS'::incident_status
            WHEN number % 7 = 0 THEN 'PENDING'::incident_status
            WHEN number % 5 = 0 THEN 'RESOLVED'::incident_status
            ELSE 'CLOSED'::incident_status
        END AS generated_status
    FROM generate_series(1, :incident_count) AS series(number)
)
INSERT INTO incidents (
    id,
    requester_id,
    device_id,
    assignee_id,
    service_id,
    title,
    description,
    priority,
    status,
    created_at,
    first_response_at,
    resolved_at,
    sla_due_at,
    updated_at
)
SELECT
    number,
    ((number * 13 - 1) % :user_count) + 1,
    ((number * 29 - 1) % :device_count) + 1,
    ((number * 31 - 1) % :technician_count) + 1,
    ((number * 11 - 1) % 120) + 1,
    (ARRAY[
        'VPN timeout during connection',
        'Printer connection refused',
        'Application access denied',
        'Database error in reporting service',
        'DNS failure resolving internal host',
        'Authentication failed after password reset',
        'Worker out of memory',
        'Slow response from customer portal'
    ])[((number - 1) % 8) + 1] || format(' [%s]', number),
    format(
        'Deterministic incident %s for correlation ID DEMO-%s. No real customer data is present.',
        number,
        lpad(number::text, 10, '0')
    ),
    generated_priority,
    generated_status,
    opened_at,
    opened_at + ((number * 7) % 180) * INTERVAL '1 minute',
    CASE
        WHEN generated_status IN ('RESOLVED', 'CLOSED')
            THEN opened_at + (30 + (number * 37) % 10000) * INTERVAL '1 minute'
    END,
    opened_at + CASE generated_priority
        WHEN 'P1' THEN INTERVAL '2 hours'
        WHEN 'P2' THEN INTERVAL '8 hours'
        WHEN 'P3' THEN INTERVAL '24 hours'
        ELSE INTERVAL '72 hours'
    END,
    opened_at + ((number * 19) % 1440) * INTERVAL '1 minute'
FROM generated;

INSERT INTO incident_comments (
    id,
    incident_id,
    incident_created_at,
    author_kind,
    author_id,
    body,
    created_at
)
SELECT
    id,
    id,
    created_at,
    CASE WHEN id % 5 = 0 THEN 'REQUESTER' ELSE 'TECHNICIAN' END,
    CASE WHEN id % 5 = 0 THEN requester_id ELSE assignee_id END,
    format('Initial deterministic comment for incident %s.', id),
    created_at + INTERVAL '5 minutes'
FROM incidents;

INSERT INTO incident_comments (
    id,
    incident_id,
    incident_created_at,
    author_kind,
    author_id,
    body,
    created_at
)
SELECT
    :incident_count + id,
    id,
    created_at,
    'TECHNICIAN',
    assignee_id,
    format('Follow-up deterministic comment for incident %s.', id),
    created_at + INTERVAL '30 minutes'
FROM incidents
WHERE id % 4 = 0;

INSERT INTO incident_assignments (
    id,
    incident_id,
    incident_created_at,
    technician_id,
    assigned_at,
    unassigned_at
)
SELECT
    id,
    id,
    created_at,
    assignee_id,
    created_at + INTERVAL '2 minutes',
    CASE WHEN id % 9 = 0 THEN created_at + INTERVAL '20 minutes' END
FROM incidents;

INSERT INTO incident_assignments (
    id,
    incident_id,
    incident_created_at,
    technician_id,
    assigned_at,
    unassigned_at
)
SELECT
    :incident_count + id,
    id,
    created_at,
    ((assignee_id + 16) % :technician_count) + 1,
    created_at + INTERVAL '21 minutes',
    NULL
FROM incidents
WHERE id % 9 = 0;

INSERT INTO sla_events (
    id,
    incident_id,
    incident_created_at,
    event_type,
    target_at,
    occurred_at,
    breached
)
SELECT
    id,
    id,
    created_at,
    'FIRST_RESPONSE',
    created_at + CASE priority
        WHEN 'P1' THEN INTERVAL '15 minutes'
        WHEN 'P2' THEN INTERVAL '1 hour'
        WHEN 'P3' THEN INTERVAL '4 hours'
        ELSE INTERVAL '8 hours'
    END,
    first_response_at,
    first_response_at > created_at + CASE priority
        WHEN 'P1' THEN INTERVAL '15 minutes'
        WHEN 'P2' THEN INTERVAL '1 hour'
        WHEN 'P3' THEN INTERVAL '4 hours'
        ELSE INTERVAL '8 hours'
    END
FROM incidents;

INSERT INTO sla_events (
    id,
    incident_id,
    incident_created_at,
    event_type,
    target_at,
    occurred_at,
    breached
)
SELECT
    :incident_count + id,
    id,
    created_at,
    'RESOLUTION',
    sla_due_at,
    resolved_at,
    resolved_at IS NULL OR resolved_at > sla_due_at
FROM incidents;

INSERT INTO software_installations (
    id,
    device_id,
    software_id,
    installed_version,
    installed_at,
    last_seen_at
)
SELECT
    ((device.id - 1) * 3) + slot.number,
    device.id,
    ((device.id * 17 + slot.number * 31 - 1) % 500) + 1,
    CASE WHEN (device.id + slot.number) % 5 = 0
        THEN software.minimum_supported_version
        ELSE software.current_version
    END,
    TIMESTAMPTZ '2024-01-01 00:00:00+00' + ((device.id + slot.number) % 365) * INTERVAL '1 day',
    TIMESTAMPTZ '2025-12-31 00:00:00+00'
FROM devices AS device
CROSS JOIN generate_series(1, 3) AS slot(number)
JOIN software_catalog AS software
  ON software.id = ((device.id * 17 + slot.number * 31 - 1) % 500) + 1;

SELECT setval(
    pg_get_serial_sequence('software_installations', 'id'),
    (SELECT max(id) FROM software_installations),
    true
);

INSERT INTO dataset_manifest (
    singleton,
    user_count,
    device_count,
    technician_count,
    incident_count
) VALUES (
    true,
    :user_count,
    :device_count,
    :technician_count,
    :incident_count
);

COMMIT;
ANALYZE;
\timing off
