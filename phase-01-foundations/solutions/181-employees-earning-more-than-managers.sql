-- 181. Employees Earning More Than Their Managers  (Easy)
-- Pattern: self-join (table aliased as employee + manager).
-- Use INNER JOIN, not LEFT: WHERE e.salary > m.salary already requires a
-- manager to exist, so a LEFT JOIN + WHERE on the right table's column collapses
-- to an inner join anyway. INNER states the intent. (LEFT + WHERE on right-side
-- column = accidental inner join — common review flag.)

SELECT e.name AS Employee
FROM   Employee e
JOIN   Employee m ON e.managerId = m.id
WHERE  e.salary > m.salary;
