-- Full-text search over title and description.
SELECT id, title, priority, status, created_at,
       ts_rank(search_document, websearch_to_tsquery('english', 'authentication failed')) AS relevance
FROM incidents
WHERE search_document @@ websearch_to_tsquery('english', 'authentication failed')
ORDER BY relevance DESC, created_at DESC
LIMIT 100;
