-- Recursive organization path from root to descendant.
WITH RECURSIVE organization AS (
    SELECT id, parent_id, name, name::text AS path, 0 AS depth
    FROM departments
    WHERE parent_id IS NULL
    UNION ALL
    SELECT child.id, child.parent_id, child.name,
           organization.path || ' > ' || child.name,
           organization.depth + 1
    FROM departments child
    JOIN organization ON organization.id = child.parent_id
)
SELECT * FROM organization ORDER BY path;
