-- Resolution performance by incident weekday.
SELECT extract(isodow FROM created_at)::integer AS weekday,
       round(avg(extract(epoch FROM resolved_at - created_at) / 60.0), 2) AS average_resolution_minutes
FROM incidents
WHERE resolved_at IS NOT NULL
GROUP BY weekday
ORDER BY weekday;
