# Performance methodology

## Objective

The benchmark compares ten defined SQL statements before and after the indexes in `optimization/apply.sql`. It measures one controlled environment; it does not claim universal speedups.

## Reproduction

```bash
make clean
SEED_SCALE=1 make setup
make benchmark
```

The manual GitHub workflow provides a second reproducible environment. It refuses to run unless the operator enters `RUN_FULL_BENCHMARK`.

## Controls

- The deterministic generator produces the same rows for the same scale.
- The full benchmark verifies counts from `dataset_manifest`.
- Baseline removes only the optional analytical indexes, then analyzes relations.
- Optimized creates the declared indexes, then analyzes relations.
- Each recorded case follows an unrecorded warm-up execution.
- Every captured plan uses `ANALYZE`, `BUFFERS`, `WAL`, `SETTINGS`, and `SUMMARY`.
- Metadata records UTC capture time, commit, PostgreSQL version, database size, and relation counts.
- Raw plans remain the primary evidence; `summary.csv` is derived from PostgreSQL's `Execution Time` line.

## Interpretation

Elapsed time alone is noisy. Review scan type, actual versus estimated rows, loops, heap fetches, buffer hits/reads, sort method, and partition pruning. A faster result with substantially greater storage or write amplification may still be a poor production trade-off.

GitHub-hosted runners are shared infrastructure and can vary. Published results state the environment and are not service-level guarantees. No result is published when a job fails or when the full row counts are not verified.
