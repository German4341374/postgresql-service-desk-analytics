# Migration failure runbook

The runner wraps each migration in a transaction, stores its SHA-256 checksum, and serializes runners with an advisory lock.

## Before migration

- Verify a recent restore-tested backup.
- Review lock levels, table rewrites, disk headroom, and expected duration.
- Stop competing schema changes.
- For large production tables, split long backfills from constraint validation and index creation.

## On failure

1. Stop additional deploy attempts.
2. Capture the exact error, migration version, PostgreSQL logs, locks, and disk state.
3. Confirm the failed transaction rolled back and inspect `schema_migrations`.
4. Do not edit a migration already recorded as applied.
5. If no migration record exists, correct the unapplied migration on the branch and retry after review.
6. If application code is incompatible with the old schema, roll the application back to its compatible version.
7. Restore into a separate database only when transactional rollback cannot recover external or operational effects.

A checksum mismatch is an integrity failure. Add a new corrective migration instead of changing history.
