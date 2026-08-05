-- 182. Duplicate Emails  (Easy)
-- Pattern: duplicate detection = GROUP BY col HAVING COUNT(*) > 1.
-- COUNT(email) works only because email is non-nullable; on a nullable column
-- COUNT(email) != COUNT(*).

SELECT email
FROM   Person
GROUP BY email
HAVING COUNT(*) > 1;
