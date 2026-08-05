-- 1873. Calculate Special Bonus  (Easy)
-- Pattern: CASE WHEN + sargable prefix match.
-- Note: name NOT LIKE 'M%' is sargable (prefix = range seek); SUBSTRING/LEFT
-- would not be. CASE routes UNKNOWN to ELSE, so a NULL name would fall to 0 —
-- fine here (name is non-nullable), but that's the branch to watch if it weren't.

SELECT employee_id,
       CASE
           WHEN employee_id % 2 = 1 AND name NOT LIKE 'M%' THEN salary
           ELSE 0
       END AS bonus
FROM   Employees
ORDER BY employee_id;
