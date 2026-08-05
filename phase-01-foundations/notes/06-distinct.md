# 06 — DISTINCT

> Phase 1: Foundations Refresher

## Concept Overview

`DISTINCT` removes duplicate rows from a result set. The one thing to
internalize: **it operates on the entire `SELECT` row, not on a single column.**
`SELECT DISTINCT a, b` dedups on the *combination* `(a, b)` — it does **not**
give distinct `a` values with some arbitrary `b`. Nearly every `DISTINCT` bug
traces back to forgetting that.

From logical execution order ([01](./01-select-where-orderby-limit.md)),
`DISTINCT` runs **after `SELECT`** — so it dedups the projected columns and can
see `SELECT` aliases (unlike `WHERE`).

## Key Syntax

```sql
SELECT DISTINCT department_id             -- distinct single column
FROM   employee;

SELECT DISTINCT department_id, job_title  -- distinct COMBINATIONS of the pair
FROM   employee;

SELECT COUNT(DISTINCT department_id)      -- distinct-count (NULLs skipped)
FROM   employee;
```

Postgres also has `DISTINCT ON`, non-standard but very useful:

```sql
SELECT DISTINCT ON (department_id) department_id, name, salary
FROM   employee
ORDER  BY department_id, salary DESC;     -- highest-paid person per department
```

`DISTINCT ON (cols)` keeps the **first row per group** as ordered by `ORDER BY` —
a compact "top-1-per-group" that most other engines need a window function for.

## Worked Example

The trap, made concrete. "List the departments that have employees":

```sql
-- CORRECT
SELECT DISTINCT department_id FROM employee;

-- WRONG — does NOT do what it looks like
SELECT DISTINCT department_id, name FROM employee;
```

The second returns essentially every row: `(department_id, name)` pairs are
nearly all unique, so adding `name` changes what "duplicate" means. `DISTINCT`
isn't attached to `department_id`; it applies to the whole projected row.

## Common Pitfalls

- **Row-wide, not column-wide.** The `SELECT DISTINCT a, b` misconception above.
  It's a keyword over the entire select list, not a function on the first column.
- **`DISTINCT` treats NULLs as equal.** Multiple NULL rows collapse to one — the
  opposite of `NULL = NULL` being UNKNOWN in `WHERE`. It uses
  `IS NOT DISTINCT FROM` semantics (like `GROUP BY`). Worth saying out loud:
  *"For dedup, NULLs group together; for equality in a join/filter, they don't."*
- **`DISTINCT` vs `GROUP BY` for dedup.** `SELECT DISTINCT a` and
  `SELECT a ... GROUP BY a` give identical results and usually identical plans.
  `DISTINCT` reads better for pure dedup; `GROUP BY` when you also need an
  aggregate. Using both together (`SELECT DISTINCT a, COUNT(*) ... GROUP BY a`)
  is redundant — a smell.
- **`COUNT(DISTINCT col)` skips NULLs.** So it can be *less* than the number of
  `GROUP BY` groups. On the seeded table, `COUNT(DISTINCT department_id)` = 3,
  though `GROUP BY department_id` yields 4 groups (the NULL department is a group
  but not a counted distinct value).
- **`DISTINCT` hides duplicates instead of explaining them.** Slapping it on to
  make counts "look right" often masks a fan-out join bug. The senior instinct is
  to ask *why* there are duplicates, not paper over them.
- **Performance.** `DISTINCT` forces a sort or hash to dedup — not free at scale.
  If duplicates come from a join, fixing the join beats deduping after.

## Interview Framing

> **"What does `SELECT DISTINCT a, b` return?"**
> Distinct *combinations* of `(a, b)`, not distinct `a`. The most common
> `DISTINCT` check — miss it and you look like a copy-paster.

> **"`DISTINCT` vs `GROUP BY` — when each?"**
> Same result for pure dedup, often the same plan. `GROUP BY` when an aggregate
> is needed alongside; `DISTINCT` for clean dedup. Bonus: Postgres `DISTINCT ON`
> for top-1-per-group.

The senior tell: when you *see* unexpected duplicates, diagnosing the cause
(usually a one-to-many join fanning out) beats reflexively adding `DISTINCT`.
Interviewers plant fan-out joins to see which you do.

## Related Real-World Application

In Spark, `DISTINCT` and `COUNT(DISTINCT ...)` trigger a **shuffle** — among the
more expensive operations at scale, since deduping gathers equal values onto the
same partition. For approximate distinct counts on huge data, Spark/warehouses
offer `approx_count_distinct` (HyperLogLog) — far cheaper when exactness isn't
required, worth naming in a Databricks-flavored interview. The "`DISTINCT`
masking a fan-out join" antipattern is a real data-quality trap: it inflates
compute and hides a modeling bug that belongs upstream.

---

[← Prev: GROUP BY / HAVING](./05-group-by-having.md) | [Back to Phase 1 index](../README.md)
