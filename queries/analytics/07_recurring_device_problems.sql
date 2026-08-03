-- Devices with repeated incidents and their last occurrence.
SELECT device_id, count(*) AS incident_count, max(created_at) AS latest_incident
FROM incidents
GROUP BY device_id
HAVING count(*) >= 5
ORDER BY incident_count DESC, device_id
LIMIT 100;
