-- Incident count normalized by device population.
WITH populations AS (
    SELECT device_type, count(*) AS devices FROM devices GROUP BY device_type
), volumes AS (
    SELECT d.device_type, count(*) AS incidents
    FROM incidents i JOIN devices d ON d.id = i.device_id
    GROUP BY d.device_type
)
SELECT p.device_type, p.devices, v.incidents,
       round(v.incidents::numeric / p.devices, 4) AS incidents_per_device
FROM populations p JOIN volumes v USING (device_type)
ORDER BY incidents_per_device DESC;
