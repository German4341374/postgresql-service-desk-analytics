-- Installations below the catalog's current version in the deterministic seed.
SELECT s.id, s.name, i.installed_version, s.current_version, count(*) AS devices
FROM software_installations i
JOIN software_catalog s ON s.id = i.software_id
WHERE i.installed_version <> s.current_version
GROUP BY s.id, s.name, i.installed_version, s.current_version
ORDER BY devices DESC, s.id
LIMIT 100;
