-- Incident volume by user creation cohort and incident year.
SELECT date_trunc('quarter', u.created_at)::date AS user_cohort,
       extract(year FROM i.created_at)::integer AS incident_year,
       count(*) AS incidents
FROM service_desk_users u
JOIN incidents i ON i.requester_id = u.id
GROUP BY user_cohort, incident_year
ORDER BY user_cohort, incident_year;
