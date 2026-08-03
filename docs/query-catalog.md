# Analytical query catalog

Every query is read-only and can be executed independently after `make setup`.

| # | File | Business question or PostgreSQL technique |
| ---: | --- | --- |
| 1 | `01_open_p1_incidents.sql` | Current highest-priority backlog |
| 2 | `02_overdue_sla.sql` | Open incidents beyond resolution deadline |
| 3 | `03_average_resolution_by_priority.sql` | Mean resolution duration by priority |
| 4 | `04_resolution_percentiles.sql` | Median, p90, and p95 resolution time |
| 5 | `05_technician_workload.sql` | Active ownership by technician |
| 6 | `06_technician_workload_rank.sql` | Workload ranking with window functions |
| 7 | `07_recurring_device_problems.sql` | Devices with repeated incidents |
| 8 | `08_frequent_requesters.sql` | Requesters generating the most demand |
| 9 | `09_monthly_incident_trend.sql` | Monthly volume trend |
| 10 | `10_first_response_metrics.sql` | First-response SLA measurements |
| 11 | `11_sla_compliance_by_service.sql` | SLA compliance grouped by service |
| 12 | `12_seven_day_moving_average.sql` | Moving average over daily counts |
| 13 | `13_running_incident_total.sql` | Running cumulative incident total |
| 14 | `14_department_hierarchy.sql` | Recursive department tree traversal |
| 15 | `15_full_text_problem_search.sql` | Ranked PostgreSQL full-text search |
| 16 | `16_top_installed_software.sql` | Most widely installed software |
| 17 | `17_outdated_software.sql` | Devices using non-current versions |
| 18 | `18_incident_rate_by_device_type.sql` | Incident rate normalized by device type |
| 19 | `19_service_mttr_window.sql` | Service MTTR compared with global window values |
| 20 | `20_backlog_aging_buckets.sql` | Operational aging buckets |
| 21 | `21_requester_cohort_analysis.sql` | Requester cohorts by first incident month |
| 22 | `22_month_over_month_change.sql` | `lag`-based volume change |
| 23 | `23_technician_percent_rank.sql` | Relative technician workload |
| 24 | `24_rolling_sla_breach_rate.sql` | Rolling breach percentage |
| 25 | `25_materialized_monthly_sla.sql` | Pre-aggregated monthly SLA view |
| 26 | `26_materialized_technician_workload.sql` | Pre-aggregated technician workload view |
| 27 | `27_normalized_error_patterns.sql` | Repeated message-pattern grouping |
| 28 | `28_incidents_without_comments.sql` | Collaboration/data-quality gap |
| 29 | `29_reassignment_frequency.sql` | Incidents with ownership churn |
| 30 | `30_sla_breach_timeline.sql` | Breach events over time |
| 31 | `31_department_risk.sql` | Department backlog and breach risk |
| 32 | `32_service_criticality_backlog.sql` | Backlog by service criticality |
| 33 | `33_expiring_warranties.sql` | Warranty exposure among active devices |
| 34 | `34_hourly_incident_heatmap.sql` | Weekday/hour arrival heatmap |
| 35 | `35_weekday_resolution.sql` | Resolution behavior by weekday |
| 36 | `36_comment_resolution_relationship.sql` | Comment volume versus resolution duration |
| 37 | `37_p1_service_pareto.sql` | Cumulative P1 contribution by service |
| 38 | `38_partition_row_distribution.sql` | Approximate rows by physical partition |
| 39 | `39_partition_sizes.sql` | Partition storage footprint |
| 40 | `40_data_quality_checks.sql` | Referential and temporal invariants |

The ten files under `optimization/queries/` intentionally focus on selective access paths that can demonstrate measurable plan changes. Their results are described separately because query timing is environment-specific.
