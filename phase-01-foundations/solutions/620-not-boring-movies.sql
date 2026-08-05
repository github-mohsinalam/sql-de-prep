-- 620. Not Boring Movies  (Easy)
-- Pattern: WHERE with modulo (odd id) + ORDER BY.
-- Note: used IS DISTINCT FROM (NULL-safe) instead of != so a NULL description
-- would still count as "not boring". Equivalent here since description is
-- non-nullable; != 'boring' also passes. The point is stating the nullability
-- assumption — if the column were nullable, the two diverge.

SELECT id, movie, description, rating
FROM   Cinema
WHERE  description IS DISTINCT FROM 'boring'
  AND  id % 2 = 1
ORDER BY rating DESC;
