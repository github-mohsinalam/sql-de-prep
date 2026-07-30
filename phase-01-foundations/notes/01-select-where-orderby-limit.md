# 01 — SELECT / WHERE / ORDER BY / LIMIT

> Phase 1: Foundations Refresher

## Concept Overview

The four clauses that define *what columns*, *which rows*, *in what order*, and
*how many*. The thing worth re-internalizing is **logical execution order**,
which is **not** the order you write the clauses in:

```
FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT
```

This one fact explains most of the "why doesn't this work?" moments in the rest
of the phase — e.g. why a `SELECT` alias is **not** available in `WHERE` (the
alias doesn't exist yet at `WHERE` time) but **is** available in `ORDER BY` (by
then `SELECT` has run).

## Key Syntax

```sql
SELECT   col_a, col_b * 2 AS doubled
FROM     table_name
WHERE    predicate
ORDER BY col_a DESC NULLS LAST, col_b ASC
LIMIT    10 OFFSET 20;
```

- `ASC` is the default sort direction.
- Postgres NULL ordering defaults: `NULLS LAST` for `ASC`, `NULLS FIRST` for
  `DESC`. Override explicitly (`NULLS LAST` / `NULLS FIRST`) when it matters.
- `LIMIT n OFFSET m` is Postgres/MySQL syntax. ANSI-standard equivalent (also
  accepted by SQL Server / Databricks):
  `OFFSET m ROWS FETCH NEXT n ROWS ONLY`.

## Worked Example

Third-highest-paid employee, excluding unpaid interns:

```sql
SELECT name, salary
FROM   employee
WHERE  salary IS NOT NULL
ORDER BY salary DESC
LIMIT 1 OFFSET 2;
```

## Common Pitfalls

- **Alias in `WHERE`.**
  `SELECT salary*12 AS annual FROM employee WHERE annual > 100000` fails —
  `annual` doesn't exist at `WHERE` time. Repeat the expression, or wrap in a
  subquery/CTE.
- **`LIMIT` without `ORDER BY`** is non-deterministic. Fine for eyeballing data,
  a bug in production.
- **Ties at the boundary.** `ORDER BY salary DESC LIMIT 1 OFFSET 2` returns the
  3rd *row*, not the 3rd *distinct salary*. That distinction is exactly what
  LeetCode 176/177 test — and why window functions (Phase 4) are the real
  answer for "Nth distinct" problems.
- **`OFFSET` on large tables is O(offset)** — the DB scans and discards the
  skipped rows. Relevant for the Phase 7 performance conversation.

## Interview Framing

> "Walk me through what the database actually does with this query."

Answering with **logical execution order** rather than reading the clauses
top-to-bottom immediately signals you understand the engine, not just the
syntax. Common follow-up bait: *"What if there are ties?"* — volunteer the
tie-handling assumption yourself before they ask.

## Related Real-World Application

Logical execution order is engine-agnostic — Spark SQL / Databricks evaluate the
same way, so the alias-in-`WHERE` restriction and the `WHERE`-vs-`HAVING` split
carry over unchanged. `OFFSET`-based pagination is an anti-pattern at scale in
any engine (keyset/seek pagination is preferred); worth knowing for both
interviews and real pipeline work.  

----
[Next: Filtering →](./02-filtering-in-between-like-null.md)
