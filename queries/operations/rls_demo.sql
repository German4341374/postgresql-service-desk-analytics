SET ROLE sd_department_analyst;
SET app.current_department_id = '1';
SELECT department_id, note
FROM department_notes
ORDER BY id;
RESET ROLE;
