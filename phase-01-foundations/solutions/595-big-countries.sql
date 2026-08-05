-- 595. Big Countries  (Easy)
-- Pattern: WHERE with OR across two columns.
-- Note: OR across different columns is usually non-sargable (can't use one
-- index for both). At scale, rewrite as UNION of two single-column filters so
-- each branch uses its own index. Not worth it here; relevant for Phase 7.

SELECT name, population, area
FROM   World
WHERE  area >= 3000000
   OR  population >= 25000000;
