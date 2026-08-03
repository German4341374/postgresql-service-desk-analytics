CREATE TYPE incident_priority AS ENUM ('P1', 'P2', 'P3', 'P4');
CREATE TYPE incident_status AS ENUM ('OPEN', 'IN_PROGRESS', 'PENDING', 'RESOLVED', 'CLOSED');
CREATE TYPE device_status AS ENUM ('ACTIVE', 'REPAIR', 'RETIRED');
CREATE TYPE sla_event_type AS ENUM ('FIRST_RESPONSE', 'RESOLUTION');

CREATE TABLE departments (
    id integer PRIMARY KEY,
    parent_id integer REFERENCES departments(id) ON DELETE RESTRICT,
    name text NOT NULL UNIQUE,
    cost_center text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    CHECK (parent_id IS NULL OR parent_id <> id)
);

CREATE TABLE service_desk_users (
    id bigint PRIMARY KEY,
    department_id integer NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
    full_name text NOT NULL,
    email text NOT NULL UNIQUE,
    location text NOT NULL,
    active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    CHECK (email = lower(email))
);

CREATE TABLE technicians (
    id bigint PRIMARY KEY,
    department_id integer NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
    display_name text NOT NULL,
    skill_tier smallint NOT NULL CHECK (skill_tier BETWEEN 1 AND 4),
    active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    updated_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE services (
    id integer PRIMARY KEY,
    name text NOT NULL UNIQUE,
    owner_department_id integer NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
    criticality smallint NOT NULL CHECK (criticality BETWEEN 1 AND 4),
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    updated_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE devices (
    id bigint PRIMARY KEY,
    assigned_user_id bigint NOT NULL REFERENCES service_desk_users(id) ON DELETE RESTRICT,
    asset_tag text NOT NULL UNIQUE,
    hostname text NOT NULL UNIQUE,
    device_type text NOT NULL CHECK (device_type IN ('LAPTOP', 'DESKTOP', 'MOBILE', 'THIN_CLIENT')),
    operating_system text NOT NULL,
    status device_status NOT NULL,
    purchased_at date NOT NULL,
    warranty_until date NOT NULL,
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    CHECK (warranty_until >= purchased_at)
);

CREATE TABLE software_catalog (
    id integer PRIMARY KEY,
    name text NOT NULL,
    vendor text NOT NULL,
    current_version text NOT NULL,
    minimum_supported_version text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    UNIQUE (name, vendor)
);

CREATE TABLE incidents (
    id bigint NOT NULL,
    requester_id bigint NOT NULL REFERENCES service_desk_users(id) ON DELETE RESTRICT,
    device_id bigint REFERENCES devices(id) ON DELETE RESTRICT,
    assignee_id bigint REFERENCES technicians(id) ON DELETE RESTRICT,
    service_id integer NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
    title text NOT NULL,
    description text NOT NULL,
    priority incident_priority NOT NULL,
    status incident_status NOT NULL,
    created_at timestamptz NOT NULL,
    first_response_at timestamptz,
    resolved_at timestamptz,
    sla_due_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    search_document tsvector GENERATED ALWAYS AS (
        to_tsvector('english'::regconfig, coalesce(title, '') || ' ' || coalesce(description, ''))
    ) STORED,
    PRIMARY KEY (id, created_at),
    CHECK (first_response_at IS NULL OR first_response_at >= created_at),
    CHECK (resolved_at IS NULL OR resolved_at >= created_at),
    CHECK (sla_due_at > created_at)
) PARTITION BY RANGE (created_at);

DO $partitioning$
DECLARE
    month_start date := DATE '2023-01-01';
    month_end date;
    partition_name text;
BEGIN
    WHILE month_start < DATE '2026-01-01' LOOP
        month_end := (month_start + INTERVAL '1 month')::date;
        partition_name := format('incidents_%s', to_char(month_start, 'YYYY_MM'));
        EXECUTE format(
            'CREATE TABLE %I PARTITION OF incidents FOR VALUES FROM (%L) TO (%L)',
            partition_name,
            month_start,
            month_end
        );
        month_start := month_end;
    END LOOP;
END
$partitioning$;

CREATE TABLE incidents_default PARTITION OF incidents DEFAULT;

CREATE TABLE incident_comments (
    id bigint PRIMARY KEY,
    incident_id bigint NOT NULL,
    incident_created_at timestamptz NOT NULL,
    author_kind text NOT NULL CHECK (author_kind IN ('REQUESTER', 'TECHNICIAN', 'SYSTEM')),
    author_id bigint,
    body text NOT NULL,
    created_at timestamptz NOT NULL,
    FOREIGN KEY (incident_id, incident_created_at)
        REFERENCES incidents(id, created_at) ON DELETE CASCADE
);

CREATE TABLE incident_assignments (
    id bigint PRIMARY KEY,
    incident_id bigint NOT NULL,
    incident_created_at timestamptz NOT NULL,
    technician_id bigint NOT NULL REFERENCES technicians(id) ON DELETE RESTRICT,
    assigned_at timestamptz NOT NULL,
    unassigned_at timestamptz,
    FOREIGN KEY (incident_id, incident_created_at)
        REFERENCES incidents(id, created_at) ON DELETE CASCADE,
    CHECK (unassigned_at IS NULL OR unassigned_at >= assigned_at)
);

CREATE TABLE sla_events (
    id bigint PRIMARY KEY,
    incident_id bigint NOT NULL,
    incident_created_at timestamptz NOT NULL,
    event_type sla_event_type NOT NULL,
    target_at timestamptz NOT NULL,
    occurred_at timestamptz,
    breached boolean NOT NULL,
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    FOREIGN KEY (incident_id, incident_created_at)
        REFERENCES incidents(id, created_at) ON DELETE CASCADE,
    UNIQUE (incident_id, incident_created_at, event_type)
);

CREATE TABLE software_installations (
    id bigint PRIMARY KEY,
    device_id bigint NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    software_id integer NOT NULL REFERENCES software_catalog(id) ON DELETE RESTRICT,
    installed_version text NOT NULL,
    installed_at timestamptz NOT NULL,
    last_seen_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    UNIQUE (device_id, software_id),
    CHECK (last_seen_at >= installed_at)
);

CREATE TABLE incident_audit_log (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    incident_id bigint NOT NULL,
    incident_created_at timestamptz NOT NULL,
    operation text NOT NULL CHECK (operation IN ('UPDATE', 'DELETE')),
    changed_by text NOT NULL,
    request_id text,
    old_row jsonb,
    new_row jsonb,
    changed_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE retention_runs (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cutoff timestamptz NOT NULL,
    dry_run boolean NOT NULL,
    candidate_rows bigint NOT NULL,
    deleted_rows bigint NOT NULL,
    executed_by text NOT NULL,
    executed_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE dataset_manifest (
    singleton boolean PRIMARY KEY DEFAULT true CHECK (singleton),
    user_count bigint NOT NULL,
    device_count bigint NOT NULL,
    technician_count bigint NOT NULL,
    incident_count bigint NOT NULL,
    generated_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE department_notes (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_id integer NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    note text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    UNIQUE (department_id, note)
);
