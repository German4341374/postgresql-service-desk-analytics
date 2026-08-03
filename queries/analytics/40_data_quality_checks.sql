-- Compact integrity dashboard for nullable lifecycle timestamps.
SELECT
    count(*) FILTER (WHERE first_response_at < created_at) AS invalid_first_response,
    count(*) FILTER (WHERE resolved_at < created_at) AS invalid_resolution,
    count(*) FILTER (WHERE status IN ('RESOLVED', 'CLOSED') AND resolved_at IS NULL) AS completed_without_resolution,
    count(*) FILTER (WHERE status IN ('OPEN', 'IN_PROGRESS', 'PENDING') AND resolved_at IS NOT NULL) AS active_with_resolution
FROM incidents;
