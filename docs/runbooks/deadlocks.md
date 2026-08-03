# Deadlock runbook

## Symptoms

PostgreSQL aborts one transaction with `deadlock detected`. The application may report a transient 40P01 SQLSTATE, while database logs include the wait graph.

## Response

1. Preserve the full PostgreSQL log entry and application correlation identifiers.
2. Identify the statements, object types, and lock acquisition order in every participant.
3. Retry only the aborted transaction, with bounded exponential backoff and idempotent application logic.
4. Change all code paths to acquire the same resources in the same deterministic order.
5. Keep transactions short and avoid network calls while holding database locks.
6. Reproduce under a controlled test before release.

Run `make deadlock` to see the project deliberately use opposite row order, assert that one transaction is aborted, and then complete both transactions after taking row locks in ascending ID order.

Do not “fix” deadlocks by increasing `deadlock_timeout`; that changes detection latency, not the cycle.
