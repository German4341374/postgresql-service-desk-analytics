DO $roles$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sd_public_reader') THEN
        CREATE ROLE sd_public_reader NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sd_department_analyst') THEN
        CREATE ROLE sd_department_analyst NOLOGIN;
    END IF;
END
$roles$;

GRANT USAGE ON SCHEMA public TO sd_public_reader, sd_department_analyst;
GRANT SELECT ON services, mv_monthly_sla_metrics TO sd_public_reader;
GRANT SELECT ON departments, department_notes TO sd_department_analyst;

ALTER TABLE department_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE department_notes FORCE ROW LEVEL SECURITY;

CREATE POLICY department_notes_isolation ON department_notes
    FOR SELECT
    TO sd_department_analyst
    USING (
        department_id = nullif(current_setting('app.current_department_id', true), '')::integer
    );
