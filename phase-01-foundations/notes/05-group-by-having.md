# 05 — GROUP BY / HAVING

> Phase 1: Foundations Refresher

## Concept Overview

`GROUP BY` collapses rows into groups — one output row per distinct combination
of the grouping columns — and every aggregate (see
[04](./04-aggregate-functions.md)) now fires **per group** instead of over the
whole table. `HAVING` then filters those groups using aggregate results that
don't exist yet at `WHERE` time.

The mental model, straight from logical execution order
([01](./01-select-where-orderby-limit.md)):

```
WHERE    → filters individual ROWS   (before grouping, no aggregates allowed)
GROUP BY → forms the groups
HAVING   → filters GROUPS             (after grouping, aggregates allowed)
```

The rule that answers half the interview questions on this topic:
**`WHERE` filters rows, `HAVING` filters groups.** Condition about a raw column
value → `WHERE`. Condition about an aggregate → `HAVING`.

## Key Syntax

```sql
SELECT   dept_id,
         COUNT(*)    AS headcount,
         AVG(salary) AS avg_salary
FROM     employee
WHERE    salary IS NOT NULL          -- row filter, BEFORE grouping
GROUP BY dept_id
HAVING   COUNT(*) >= 5               -- group filter, AFTER grouping
     AND AVG(salary) > 60000
ORDER BY avg_salary DESC;
```

Two hard rules:

- **Every `SELECT` column must be in `GROUP BY` or inside an aggregate.**
  `SELECT dept_id, name, COUNT(*)` without `name` grouped is an error in Postgres
  (MySQL historically returned a *random* `name` — worse, because it's silent).
- **`GROUP BY` can take multiple columns** — `GROUP BY dept_id, job_title` makes
  one group per distinct *pair*.

## Worked Example

"Departments with more than 2 employees, showing average salary — counting only
employees who actually have a salary recorded."

```sql
SELECT   dept_id,
         COUNT(*)    AS headcount,
         AVG(salary) AS avg_salary
FROM     employee
WHERE    salary IS NOT NULL          -- exclude unpaid rows before they're grouped
GROUP BY dept_id
HAVING   COUNT(*) > 2;
```

Division of labor: `WHERE salary IS NOT NULL` removes rows *before* grouping (so
they don't inflate `COUNT(*)`); `HAVING COUNT(*) > 2` discards whole small
departments *after* grouping. Each clause does a job the other can't.

## Common Pitfalls

- **Aggregate in `WHERE`.** `WHERE COUNT(*) > 2` is illegal — aggregates don't
  exist at `WHERE` time; use `HAVING`. The most common beginner error, and a
  direct logical-execution-order consequence.
- **`WHERE` vs `HAVING` when both "work."** `WHERE salary > 50000` (keep high
  earners, then group) and `HAVING MIN(salary) > 50000` (keep groups whose
  *lowest* earner clears 50k) are **different questions**, not interchangeable.
- **Non-aggregated `SELECT` column not in `GROUP BY`** → error. Add it to
  `GROUP BY` or wrap it (`MAX(name)`).
- **`COUNT(*)` vs `COUNT(col)` per group.** "Departments with ≥ 3 people who
  received a bonus" is `HAVING COUNT(bonus) >= 3`, not `COUNT(*)` — NULL bonuses
  shouldn't count.
- **No rows → no group** (not a zero row). "Departments with 0 employees" can't
  come from `GROUP BY employee`; needs a `LEFT JOIN` from `department` (Phase 2).
- **Alias in `HAVING`.** Standard SQL forbids the `SELECT` alias in `HAVING`
  (not created yet — same reason as `WHERE`). Postgres permits it as an
  extension; portable code repeats the aggregate (`HAVING COUNT(*) > 2`, not
  `HAVING headcount > 2`).

## Interview Framing

> **"Difference between `WHERE` and `HAVING`?"**
> The layup. Answer with *rows vs groups* and *before vs after grouping*, and
> note aggregates are only legal in `HAVING`. Senior nuance: *"If a condition
> doesn't reference an aggregate, I put it in `WHERE` so rows are filtered before
> grouping — smaller groups, less work."*

> **"Filter a group by `COUNT` without `HAVING`?"**
> Yes — wrap the `GROUP BY` in a subquery/CTE and filter the aggregate in an
> outer `WHERE`. The bridge to Phase 3 (subqueries).

Reflex that reads as senior: push every non-aggregate condition into `WHERE`,
reserve `HAVING` strictly for aggregate conditions — and say *why* (pre-grouping
filter = cheaper).

## Related Real-World Application

Identical in Spark SQL, and the performance point is sharper at scale: `WHERE`
predicates can be **pushed down** to the scan (predicate pushdown / partition
pruning), reading less data off disk, while `HAVING` necessarily runs *after* the
shuffle-heavy group-by. "Filter in `WHERE` when you can" isn't tidiness — in
Databricks it's the difference between pruning partitions up front and shuffling
everything then discarding. Directly relevant to Phase 7 and Phase 10.

---

[← Prev: Aggregate Functions](./04-aggregate-functions.md) | [Next: DISTINCT →](./06-distinct.md)
