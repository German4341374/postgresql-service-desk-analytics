BEGIN;
SELECT safe_upsert_software_installation(
    1,
    1,
    '9.9.9-demo',
    TIMESTAMPTZ '2026-01-02 00:00:00+00'
);
SELECT safe_upsert_software_installation(
    1,
    1,
    '1.0.0-stale-event',
    TIMESTAMPTZ '2025-01-01 00:00:00+00'
);
ROLLBACK;
