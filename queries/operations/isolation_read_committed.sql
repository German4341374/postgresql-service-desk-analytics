-- Session A: READ COMMITTED permits each statement to observe a newer committed snapshot.
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT status FROM incidents WHERE id = 1 ORDER BY created_at LIMIT 1;
-- Commit a status change from session B here, then repeat the SELECT.
SELECT status FROM incidents WHERE id = 1 ORDER BY created_at LIMIT 1;
ROLLBACK;
