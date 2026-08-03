# Contributing

Contributions should remain SQL-first, reproducible, and safe to run locally.

## Workflow

1. Create a focused branch from `main`.
2. Add new schema changes as a new immutable `migrations/VNNN__description.sql` file.
3. Use deterministic synthetic values; never commit production data, dumps, or credentials.
4. Run `bash -n scripts/*.sh`, `docker compose config --quiet`, and `make test`.
5. Document locking, storage, and plan effects for schema or index changes.
6. Use Conventional Commits, for example `feat: add SLA breach cohort query`.

Performance claims require raw `EXPLAIN ANALYZE` output, runner metadata, and exact reproduction commands. Do not replace an applied migration or publish estimated benchmark numbers as measured results.

Pull requests should be small enough to review and must explain recovery steps for migrations that can fail after partial operational rollout.
