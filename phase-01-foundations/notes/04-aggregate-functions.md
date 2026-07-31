# 04 — Aggregate Functions: COUNT, SUM, AVG, MIN, MAX

> Phase 1: Foundations Refresher

## Concept Overview

Aggregates collapse many rows into one value. The rule that connects them to the
NULL logic from [02](./02-filtering-in-between-like-null.md) /
[03](./03-anti-joins-not-in-not-exists.md): **every aggregate except `COUNT(*)`
skips NULLs entirely.** They don't treat NULL as zero — they act as if the row
weren't there. That single rule explains almost every "my average looks wrong"
bug.

## Key Syntax

```sql
SELECT COUNT(*)                AS all_rows,        -- counts rows, NULLs included
       COUNT(bonus)            AS non_null_bonus,  -- counts non-NULL bonus only
       COUNT(DISTINCT dept_id) AS num_depts,       -- distinct non-NULL values
       SUM(salary)             AS total,
       AVG(salary)             AS mean,
       MIN(hire_date)          AS earliest,
       MAX(salary)             AS highest
FROM   employee;
```

## Worked Example

The NULL-skipping behavior, made concrete. Bonuses `{100, 200, NULL, NULL, 300}`:

```sql
SELECT COUNT(*)     AS rows,        -- 5
       COUNT(bonus) AS have_bonus,  -- 3   (NULLs skipped)
       SUM(bonus)   AS total,       -- 600
       AVG(bonus)   AS avg_bonus    -- 200  = 600/3, NOT 600/5 = 120
FROM   employee;
```

`AVG` divided by **3**, not 5. To treat missing bonus as zero you must say so:

```sql
AVG(COALESCE(bonus, 0))   -- 120  = 600/5
```

Neither is "correct" — they answer different questions: *"average bonus among
those who got one"* vs *"average bonus across all staff."* Naming which one you
mean is the senior signal.

## Common Pitfalls

- **`AVG` ignores NULLs in the denominator.** The single most common aggregate
  bug. Decide `COALESCE`-first vs skip-NULLs deliberately.
- **`COUNT(*)` vs `COUNT(col)` vs `COUNT(DISTINCT col)`** — three different
  numbers: rows / non-NULL values / distinct non-NULL values.
- **Aggregate over zero rows.** `SUM`/`AVG`/`MIN`/`MAX` return **NULL** (not 0)
  when no rows match; `COUNT` returns 0. Wrap in `COALESCE(SUM(x), 0)` if
  downstream expects a number.
- **`MAX`/`MIN` on the wrong type.** `MAX(text_col)` is lexicographic — `'9' <
  '10'` is FALSE as text. Bites when a numeric ID is stored as a string.
- **Integer division in a hand-rolled average.** `SUM(int_col) / COUNT(*)`
  truncates in engines that do integer math (Postgres `NUMERIC` is safe; plain
  `INT` is not). `AVG` never has this problem.
- **No aggregates in `WHERE`, no bare non-grouped columns.** `WHERE amount =
  MAX(amount)` is illegal (that's `HAVING` — see [05](./05-group-by-having.md));
  `SELECT dept_id, SUM(salary)` needs `dept_id` in `GROUP BY`. Both are
  logical-execution-order consequences from [01](./01-select-where-orderby-limit.md).

## Interview Framing

> **"Difference between `COUNT(*)` and `COUNT(column)`?"**
> `*` counts rows; `COUNT(column)` counts non-NULL values in that column. Bonus:
> `COUNT(DISTINCT column)`.

> **"Your `AVG` came back lower/higher than expected — why?"**
> NULL handling. Either NULLs were skipped (denominator smaller than expected) or
> `COALESCE`d to 0 (denominator larger). Diagnose by comparing `COUNT(*)` to
> `COUNT(col)`.

Useful identity to state out loud: `SUM(x) / COUNT(*)` = average-treating-NULL-
as-zero (SUM skips NULLs in the numerator, `COUNT(*)` gives the full
denominator), while `SUM(x) / COUNT(x)` = `AVG(x)` = average-among-non-NULL.
Knowing both routes reads as fluency.

Reflex to build: whenever aggregating a nullable column, state whether NULLs
should count as absent or as zero *before* writing the query.

## Related Real-World Application

Identical semantics in Spark SQL. Where it bites in DE work: aggregating a
metrics column that's NULL for some event types silently under-counts unless you
`COALESCE` first, and a NULL-skipping `AVG` in a daily rollup drifts as the null
rate changes — a classic "why is this KPI wobbling?" data-quality investigation.
The zero-rows-returns-NULL rule matters in pipelines too: an empty partition's
`SUM` lands as NULL and can poison a downstream `NOT NULL` column or a division.

---

## Practice

Run against this self-contained table. **Attempt before scrolling to
[Solutions](#solutions).**

```sql
DROP TABLE IF EXISTS emp_agg;
CREATE TABLE emp_agg (
    emp_id   INT PRIMARY KEY,
    name     TEXT,
    dept_id  INT,        -- nullable: some staff unassigned
    salary   NUMERIC,    -- assume always present
    bonus    NUMERIC     -- nullable: not everyone gets one
);

INSERT INTO emp_agg VALUES
    (1, 'Alice',  10, 90000, 5000),
    (2, 'Bob',    10, 80000, NULL),
    (3, 'Carol',  20, 85000, 3000),
    (4, 'Dave',   20, 70000, NULL),
    (5, 'Eve',    NULL, 60000, NULL),   -- no department
    (6, 'Frank',  10, 75000, 2000);
```

**Problem**

> Write **one query** (no `GROUP BY`) returning six columns. Predict each value
> by hand first:
>
> 1. `total_employees` — every employee
> 2. `employees_with_bonus` — how many actually received a bonus
> 3. `distinct_departments` — how many distinct departments people are assigned to
> 4. `total_bonus_paid` — sum of all bonuses
> 5. `avg_bonus_recipients` — average bonus **among those who got one**
> 6. `avg_bonus_all_staff` — average bonus **treating no-bonus as zero**
>
> The two `avg_bonus_*` columns are the point: if they come back equal,
> something's wrong.

---

## Solutions

*Attempt the [Practice](#practice) problem above before reading.*

### Solution

```sql
SELECT COUNT(*)                     AS total_employees,       -- 6
       COUNT(bonus)                 AS employees_with_bonus,   -- 3
       COUNT(DISTINCT dept_id)      AS distinct_departments,   -- 2 (Eve's NULL skipped)
       SUM(bonus)                   AS total_bonus_paid,       -- 10000
       AVG(bonus)                   AS avg_bonus_recipients,   -- 3333.33 = 10000/3
       AVG(COALESCE(bonus, 0))      AS avg_bonus_all_staff     -- 1666.67 = 10000/6
FROM   emp_agg;
```

The two averages diverge because they use different denominators on the same
numerator: `AVG(bonus)` counts the 3 non-NULL bonuses (10000/3), while
`AVG(COALESCE(bonus,0))` counts all 6 rows (10000/6). `COUNT(DISTINCT dept_id)`
returns 2, not 3 — Eve's NULL department is skipped, same rule as plain
`COUNT(col)`.

Equivalent without `COALESCE`, using the identity from Interview Framing:

```sql
SUM(bonus) / COUNT(*)   -- 1666.67, same as AVG(COALESCE(bonus,0))
SUM(bonus) / COUNT(bonus)  -- 3333.33, same as AVG(bonus)
```

(Safe here because `bonus` is `NUMERIC`; on an `INT` column `SUM/COUNT` would
truncate — `AVG` would not.)

---

[← Prev: Anti-Joins](./03-anti-joins-not-in-not-exists.md) | [Next: GROUP BY / HAVING →](./05-group-by-having.md)
