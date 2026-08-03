-- Exact row distribution across monthly partitions.
SELECT tableoid::regclass AS partition_name, count(*) AS rows
FROM incidents
GROUP BY tableoid
ORDER BY 1;
