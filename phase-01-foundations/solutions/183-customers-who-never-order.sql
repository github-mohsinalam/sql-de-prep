-- 183. Customers Who Never Order  (Easy)
-- Pattern: anti-join via NOT EXISTS (NULL-safe, compiles to an anti-join).
-- NOT IN is risky here: customerId is an FK but FKs permit NULLs, so the
-- subquery could contain a NULL and poison the result. NOT EXISTS avoids that.

SELECT c.name AS Customers
FROM   Customers c
WHERE  NOT EXISTS (
    SELECT 1
    FROM   Orders o
    WHERE  o.customerId = c.id
);
