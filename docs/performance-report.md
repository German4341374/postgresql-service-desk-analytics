# Measured performance report

This report contains measurements from successful GitHub Actions run [30858404355](https://github.com/German4341374/postgresql-service-desk-analytics/actions/runs/30858404355) at commit `6de9ca0189164437ad47feb61b7d4541399a7b7c`. The workflow completed on 2026-08-03 between 22:22:40 and 22:28:47 UTC.

The complete evidence is committed under [`optimization/results/full-run-30858404355`](../optimization/results/full-run-30858404355). It includes all twenty raw PostgreSQL plans, metadata, index output, and the machine-readable summary. These values are specific to this runner and workload; they are not production guarantees.

## Environment

| Property | Measured value |
| --- | --- |
| Runner | GitHub-hosted `ubuntu-24.04`, x86_64 |
| CPU | 4 vCPU, Intel Xeon Platinum 8573C |
| Memory | 15 GiB reported by `free -h` |
| PostgreSQL | 18.4, Debian package `18.4-1.pgdg12+1` |
| Database size at capture | 1,315 MB |
| PostgreSQL settings | `shared_buffers=256MB`, `work_mem=32MB`, `maintenance_work_mem=256MB`, `random_page_cost=1.1`, `track_io_timing=on` |
| Plan options | `ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT` |
| Warm-up | One unrecorded execution before each saved plan |

The preparation step took 4 minutes 27 seconds, plan capture took 55 seconds, and full verification took 37 seconds according to the workflow step timestamps. Image download and container startup are included in preparation.

## Verified cardinalities

| Relation | Rows |
| --- | ---: |
| Users | 100,000 |
| Devices | 200,000 |
| Incidents | 1,000,000 |
| Comments | 1,250,000 |
| Assignments | 1,111,111 |
| SLA events | 2,000,000 |
| Software installations | 600,000 |

The workflow ran the schema assertions and all forty analytics queries after measurement. Both checks passed on this full data set.

## Results

The factor is `baseline / optimized`. Values above `1.00x` are faster after the proposed index; values below `1.00x` are slower.

| Case | Baseline ms | Optimized ms | Factor | Result |
| --- | ---: | ---: | ---: | --- |
| 01 overdue priority incidents | 504.282 | 34.220 | 14.74x | Improved |
| 02 requester timeline | 924.763 | 0.635 | 1,456.32x | Improved |
| 03 technician active workload | 208.810 | 1.044 | 200.01x | Improved |
| 04 full-text timeout search | 179.521 | 257.276 | 0.70x | Regressed |
| 05 monthly partition range | 9.713 | 6.180 | 1.57x | Improved |
| 06 device recurring incidents | 128.200 | 0.547 | 234.37x | Improved |
| 07 breached resolution events | 72.272 | 0.487 | 148.40x | Improved |
| 08 incident comment timeline | 49.894 | 0.079 | 631.57x | Improved |
| 09 software version inventory | 15.683 | 0.267 | 58.74x | Improved |
| 10 service critical backlog | 137.650 | 5.598 | 24.59x | Improved |

The exact source values are in [`summary.csv`](../optimization/results/full-run-30858404355/summary.csv). Factors above are derived from those PostgreSQL-reported execution times and rounded to two decimals.

## Plan explanations

### 01 — overdue priority incidents

The [baseline plan](../optimization/results/full-run-30858404355/baseline/01_overdue_priority_incidents.txt) used parallel sequential scans across monthly partitions and reported 59,437 shared reads. The [optimized plan](../optimization/results/full-run-30858404355/optimized/01_overdue_priority_incidents.txt) used the per-partition partial priority/SLA indexes and stopped after the ordered limit, with shared hits instead of those baseline reads. Execution fell from 504.282 ms to 34.220 ms.

### 02 — requester timeline

The [baseline](../optimization/results/full-run-30858404355/baseline/02_requester_timeline.txt) scanned every partition to find one requester's sparse history. The [optimized plan](../optimization/results/full-run-30858404355/optimized/02_requester_timeline.txt) used requester/date indexes in every partition, read 88 shared buffers, and preserved descending-date access for the limit. Execution fell from 924.763 ms to 0.635 ms.

### 03 — technician active workload

The [baseline](../optimization/results/full-run-30858404355/baseline/03_technician_active_workload.txt) used parallel sequential scans and read 59,326 shared buffers. The [optimized plan](../optimization/results/full-run-30858404355/optimized/03_technician_active_workload.txt) used per-partition index-only scans on assignee, status, date, and included columns. Execution fell from 208.810 ms to 1.044 ms.

### 04 — full-text timeout search

The [baseline](../optimization/results/full-run-30858404355/baseline/04_full_text_timeout_search.txt) used parallel sequential scans and completed in 179.521 ms. The [GIN plan](../optimization/results/full-run-30858404355/optimized/04_full_text_timeout_search.txt) used bitmap index and heap scans, but the deterministic phrase is deliberately common: roughly one eighth of incident titles match before the global date sort and limit. It read 40,232 shared buffers and completed in 257.276 ms, a 43.3% regression. The result shows that a valid index is not automatically a useful plan for a low-selectivity term. A production fix would test more selective queries, consider a date-supported search strategy, and retain planner freedom rather than forcing GIN.

### 05 — monthly partition range

Both plans pruned the query to the July 2025 partition. The [baseline](../optimization/results/full-run-30858404355/baseline/05_monthly_partition_range.txt) sequentially scanned that one partition in 9.713 ms. The [optimized plan](../optimization/results/full-run-30858404355/optimized/05_monthly_partition_range.txt) selected an index-only scan and completed in 6.180 ms. The 1.57x change is modest because reading one complete month is not highly selective; partition pruning provides most of the benefit.

### 06 — device recurring incidents

The [baseline](../optimization/results/full-run-30858404355/baseline/06_device_recurring_incidents.txt) scanned all partitions for a sparse device key. The [optimized plan](../optimization/results/full-run-30858404355/optimized/06_device_recurring_incidents.txt) used device/date indexes and only 83 shared hits. Execution fell from 128.200 ms to 0.547 ms.

### 07 — breached resolution events

The [baseline](../optimization/results/full-run-30858404355/baseline/07_breached_resolution_events.txt) performed a parallel sequential scan over two million SLA events and read 21,851 shared buffers. The [optimized plan](../optimization/results/full-run-30858404355/optimized/07_breached_resolution_events.txt) used the partial breach/target index and stopped at 500 ordered results. Execution fell from 72.272 ms to 0.487 ms.

### 08 — incident comment timeline

The [baseline](../optimization/results/full-run-30858404355/baseline/08_incident_comment_timeline.txt) parallel-scanned 1.25 million comments and read 20,987 shared buffers. The [optimized plan](../optimization/results/full-run-30858404355/optimized/08_incident_comment_timeline.txt) used the incident/date index, touched 11 shared buffers, and returned the two matching rows in order. Execution fell from 49.894 ms to 0.079 ms.

### 09 — software version inventory

The [baseline](../optimization/results/full-run-30858404355/baseline/09_software_version_inventory.txt) used the existing device-first uniqueness index, touched 4,279 shared buffers, and still filtered for software ID. The [optimized plan](../optimization/results/full-run-30858404355/optimized/09_software_version_inventory.txt) used a software/version index-only scan with 13 shared hits. Execution fell from 15.683 ms to 0.267 ms.

### 10 — service critical backlog

The [baseline](../optimization/results/full-run-30858404355/baseline/10_service_critical_backlog.txt) scanned monthly partitions and read 59,372 shared buffers. The [optimized plan](../optimization/results/full-run-30858404355/optimized/10_service_critical_backlog.txt) combined service/status/date and partial backlog indexes through index and bitmap access paths. Execution fell from 137.650 ms to 5.598 ms.

## Index storage note

The captured [`index-sizes.csv`](../optimization/results/full-run-30858404355/index-sizes.csv) reports 48 MB for the comment index, 33 MB for the partial SLA index, 30 MB for active assignments, and 23 MB for software/version. PostgreSQL reports zero bytes for each partitioned parent incident index because the parent is metadata-only; physical storage belongs to its automatically created child indexes. This run did not aggregate those child sizes, so no incident-index storage total is claimed.

## Limitations

- GitHub-hosted runner performance can vary between runs.
- Warm-cache comparison does not represent first-read latency after a restart.
- The generated distribution is deterministic and useful for reproducibility, but it is not a production workload trace.
- Index build time and write amplification are not benchmarked here.
- Case 04 proves that the proposed GIN index is not beneficial for this common term and sort pattern; it should not be promoted as an across-the-board improvement.
- Plan changes across PostgreSQL versions are expected and should be remeasured from raw evidence.

See [performance-methodology.md](performance-methodology.md) for the controlled procedure.
