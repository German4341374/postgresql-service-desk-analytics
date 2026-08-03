# Five-minute demonstration

Prepare the environment before the meeting with `cp .env.example .env && make setup`. Use the default scaled data set so the demonstration is responsive.

## 0:00–1:00 — Explain the model

Open the Mermaid architecture and the partition definition in `migrations/V001__core_schema_and_partitions.sql`. Explain why the partition key is part of the incident identity and why the default partition prevents unexpected dates from failing ingestion.

## 1:00–2:00 — Show analytics

Run:

```bash
docker compose exec -T database psql -U service_desk -d service_desk_analytics \
  -f /workspace/queries/analytics/04_resolution_percentiles.sql
```

Then show `queries/analytics/14_department_hierarchy.sql` and `15_full_text_problem_search.sql` to highlight percentiles, recursive CTEs, and PostgreSQL full-text search.

## 2:00–3:00 — Show plans, not guesses

Run `make benchmark`, open `optimization/results/generated/summary.csv`, and compare one baseline plan with its optimized plan. Point out actual scan type, buffers, rows, and execution time. State that local timings are machine-specific.

## 3:00–4:00 — Demonstrate safety controls

Run:

```bash
make migrate
make migrate
make deadlock
```

Explain migration checksums and the advisory lock. The deadlock demo proves the failure, then fixes it by locking rows in deterministic order.

## 4:00–5:00 — Demonstrate recovery and CI

Run `bash scripts/backup-restore-demo.sh`, then show the CI workflow. Explain that pull requests use a scaled deterministic data set while the manually confirmed workflow generates the full million-incident profile and uploads raw plans.
