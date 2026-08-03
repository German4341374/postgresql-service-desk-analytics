-- Incident distribution by weekday and hour.
SELECT extract(isodow FROM created_at)::integer AS weekday,
       extract(hour FROM created_at)::integer AS hour,
       count(*) AS incidents
FROM incidents
GROUP BY weekday, hour
ORDER BY weekday, hour;
