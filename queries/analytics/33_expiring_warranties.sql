-- Devices reaching warranty expiry in a fixed reporting window.
SELECT device_type, count(*) AS expiring_devices
FROM devices
WHERE warranty_until >= DATE '2025-01-01'
  AND warranty_until < DATE '2026-01-01'
  AND status <> 'RETIRED'
GROUP BY device_type
ORDER BY expiring_devices DESC;
