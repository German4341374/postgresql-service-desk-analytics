-- On-disk size of every incident partition.
SELECT child.relname AS partition_name,
       pg_total_relation_size(child.oid) AS total_bytes,
       pg_size_pretty(pg_total_relation_size(child.oid)) AS total_size
FROM pg_inherits inheritance
JOIN pg_class parent ON parent.oid = inheritance.inhparent
JOIN pg_class child ON child.oid = inheritance.inhrelid
WHERE parent.relname = 'incidents'
ORDER BY total_bytes DESC, partition_name;
