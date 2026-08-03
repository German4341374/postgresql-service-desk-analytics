BEGIN;
SELECT pg_advisory_xact_lock(hashtextextended('service-desk-reference-seed', 0));

INSERT INTO departments (id, parent_id, name, cost_center)
SELECT
    number,
    CASE WHEN number = 1 THEN NULL ELSE greatest(1, number / 10) END,
    format('Department %s', lpad(number::text, 3, '0')),
    format('CC-%s', lpad(number::text, 4, '0'))
FROM generate_series(1, 100) AS series(number)
ON CONFLICT (id) DO UPDATE
SET parent_id = EXCLUDED.parent_id,
    name = EXCLUDED.name,
    cost_center = EXCLUDED.cost_center,
    updated_at = clock_timestamp();

INSERT INTO services (id, name, owner_department_id, criticality)
SELECT
    number,
    format('Business Service %s', lpad(number::text, 3, '0')),
    ((number - 1) % 100) + 1,
    ((number - 1) % 4) + 1
FROM generate_series(1, 120) AS series(number)
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    owner_department_id = EXCLUDED.owner_department_id,
    criticality = EXCLUDED.criticality,
    updated_at = clock_timestamp();

INSERT INTO software_catalog (id, name, vendor, current_version, minimum_supported_version)
SELECT
    number,
    format('Application %s', lpad(number::text, 3, '0')),
    format('Vendor %s', lpad((((number - 1) % 25) + 1)::text, 2, '0')),
    format('%s.%s.0', ((number - 1) % 8) + 1, (number * 3) % 10),
    format('%s.%s.0', greatest(1, ((number - 1) % 8)), (number * 3) % 10)
FROM generate_series(1, 500) AS series(number)
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    vendor = EXCLUDED.vendor,
    current_version = EXCLUDED.current_version,
    minimum_supported_version = EXCLUDED.minimum_supported_version,
    updated_at = clock_timestamp();

INSERT INTO department_notes (department_id, note)
SELECT number, format('Synthetic operational note for department %s.', number)
FROM generate_series(1, 10) AS series(number)
ON CONFLICT DO NOTHING;

COMMIT;
