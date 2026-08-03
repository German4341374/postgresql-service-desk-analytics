# Security model

## Trust boundaries

The Docker host, repository checkout, and operator are trusted. PostgreSQL is reachable through a localhost-published port for convenience. Scripts execute repository-controlled SQL as the demonstration database owner. They are not designed to accept arbitrary filenames, identifiers, or SQL fragments from untrusted callers.

## Data

The generator creates fictional identities under `.invalid` domains and deterministic non-routable examples. Real Service Desk exports, logical dumps, PostgreSQL volumes, `.env` files, and generated plans must not be committed. Query plans can expose literals and schema information even when they contain no rows.

## Credentials

The password belongs only in `.env` or the CI job environment. It is intentionally not suitable for production. A production deployment should use a secret manager, TLS, rotation, short-lived credentials where possible, and distinct owner, migration, writer, reader, backup, and monitoring roles.

## RLS

The RLS demo forces department filtering for a group role. A trusted connection layer must set `app.current_department_id` with `SET LOCAL` inside every transaction. Pooling a session with stale identity context is unsafe. Table owners and superusers bypass normal privilege boundaries and must not serve application traffic.

## Backups

The local backup is neither encrypted nor off-host. Production backups should be encrypted in transit and at rest, access-controlled, monitored, retained according to policy, and restore-tested in an isolated environment.
