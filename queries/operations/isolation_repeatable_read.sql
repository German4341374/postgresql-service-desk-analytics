-- Session A: both statements use one stable snapshot; serialization errors remain possible on writes.
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT status FROM incidents WHERE id = 1 ORDER BY created_at LIMIT 1;
-- Commit a status change from session B here, then repeat the SELECT.
SELECT status FROM incidents WHERE id = 1 ORDER BY created_at LIMIT 1;
ROLLBACK;
