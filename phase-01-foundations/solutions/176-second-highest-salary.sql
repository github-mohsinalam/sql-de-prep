-- 176. Second Highest Salary  (Medium)
-- Pattern: MAX over an empty set returns NULL for free

SELECT MAX(salary) AS SecondHighestSalary
FROM   Employee
WHERE  salary < (SELECT MAX(salary) FROM Employee);


-- Alternative (also NULL-safe)
-- Pattern: scalar subquery in SELECT list -> returns NULL automatically when the
-- inner query yields no rows. That's what satisfies "return NULL if there is no
-- second salary" for free — no UNION or COALESCE needed.
--   - DISTINCT handles salary ties (2nd highest DISTINCT salary, not 2nd row).
--   - LIMIT 1 also protects the scalar contract (a scalar subquery returning >1
--     row is a runtime error).
-- Same subquery in FROM would give an empty result set instead of a NULL row;
-- the NULL-on-empty behavior is specific to scalar (SELECT-list) position.
/*
SELECT (
    SELECT DISTINCT salary
    FROM   Employee
    ORDER BY salary DESC
    LIMIT 1 OFFSET 1
) AS SecondHighestSalary;

*/
