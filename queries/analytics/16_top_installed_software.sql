-- Most widely installed software products.
SELECT s.id, s.name, s.vendor, count(*) AS installations
FROM software_catalog s
JOIN software_installations i ON i.software_id = s.id
GROUP BY s.id, s.name, s.vendor
ORDER BY installations DESC, s.id
LIMIT 50;
