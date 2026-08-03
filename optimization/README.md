# Reproducible optimization cases

The ten cases use one unchanged dataset and session configuration. `scripts/benchmark.sh` drops only the documented optional indexes, runs every `EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS)` twice, preserves the second warm-cache plan as the baseline, applies `optimization/apply.sql`, analyzes the database, and repeats the same process.

| Case | Access pattern | Intended optimization |
|---|---|---|
| 01 | Active P1/P2 incidents ordered by overdue SLA | Partial B-tree on priority and SLA deadline |
| 02 | Recent incidents for one requester | Requester/date covering B-tree |
| 03 | Active workload for one technician | Assignee/status/date covering B-tree |
| 04 | Full-text timeout search | GIN on stored `tsvector` |
| 05 | One-month aggregate | Partition pruning plus BRIN for broader range scans |
| 06 | Device incident history | Device/date covering B-tree |
| 07 | Breached resolution events in a target window | Partial B-tree on event type and target |
| 08 | Immutable incident comment timeline | Incident/date B-tree |
| 09 | Installed versions for one software product | Software/version B-tree |
| 10 | Critical backlog for a service | Service/status/date plus partial backlog indexes |

No timing is embedded in this design document. Measured values and complete plans are added only from the full GitHub Actions benchmark artifact.
