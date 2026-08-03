EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, SUMMARY, FORMAT TEXT)
SELECT installed_version, count(*) AS installation_count
FROM software_installations
WHERE software_id = 42
GROUP BY installed_version
ORDER BY installation_count DESC;
