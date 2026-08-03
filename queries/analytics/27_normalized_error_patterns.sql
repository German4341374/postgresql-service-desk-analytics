-- Group similar titles after removing deterministic numeric identifiers.
SELECT regexp_replace(title, '\\[[0-9]+\\]', '[ID]', 'g') AS normalized_title,
       count(*) AS occurrences
FROM incidents
GROUP BY normalized_title
ORDER BY occurrences DESC, normalized_title;
