-- Resolution SLA compliance by business service.
SELECT s.id, s.name,
       count(*) AS measured,
       round(100.0 * count(*) FILTER (WHERE NOT e.breached) / nullif(count(*), 0), 2) AS compliance_percent
FROM services s
JOIN incidents i ON i.service_id = s.id
JOIN sla_events e ON e.incident_id = i.id
                 AND e.incident_created_at = i.created_at
                 AND e.event_type = 'RESOLUTION'
GROUP BY s.id, s.name
ORDER BY compliance_percent, s.id;
