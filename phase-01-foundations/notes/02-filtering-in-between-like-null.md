# 02 — Filtering: IN, BETWEEN, LIKE, NULL handling

> Phase 1: Foundations Refresher

## Concept Overview

`WHERE` evaluates each row's predicate to one of **three** values —
**TRUE / FALSE / UNKNOWN**. SQL is three-valued logic, not boolean. Only rows
evaluating to **TRUE** survive; both FALSE and UNKNOWN are discarded.

UNKNOWN is produced by *any* comparison involving NULL. This is why NULL bugs are
**silent**: you don't get an error, you get missing rows.

The three operators are shorthand you should be able to unfold on demand:

- `x IN (a, b, c)` ≡ `x = a OR x = b OR x = c`
- `x BETWEEN a AND b` ≡ `x >= a AND x <= b` (inclusive on both ends)
- `LIKE` — pattern matching with `%` (any run of characters, including zero) and
  `_` (exactly one character)

## Key Syntax

```sql
SELECT *
FROM   employee
WHERE  dept_id IN (1, 2, 3)                 -- OR-chain shorthand
  AND  hire_date BETWEEN '2023-01-01'       -- inclusive both ends
                     AND '2023-12-31'
  AND  name ILIKE 'a%'                       -- Postgres: case-insensitive LIKE
  AND  manager_id IS NOT NULL                -- NEVER  != NULL
  AND  COALESCE(bonus, 0) > 500;             -- NULL-safe default
```

NULL-aware operators worth knowing **by name**:

```sql
a IS DISTINCT FROM b        -- TRUE if different, treating NULL as a comparable value
a IS NOT DISTINCT FROM b    -- TRUE if equal, and NULL = NULL counts as equal
COALESCE(a, b, c)           -- first non-NULL argument
NULLIF(a, b)                -- NULL if a = b, else a   (classic divide-by-zero guard)
```

## Worked Example

"Employees in dept 1 or 2, hired in 2023, whose bonus is under 1000 —
**including those with no bonus recorded.**"

```sql
SELECT name, bonus
FROM   employee
WHERE  dept_id IN (1, 2)
  AND  hire_date BETWEEN DATE '2023-01-01' AND DATE '2023-12-31'
  AND  (bonus < 1000 OR bonus IS NULL);
```

Drop the `OR bonus IS NULL` and every no-bonus employee silently vanishes:
`NULL < 1000` is UNKNOWN, not TRUE. This exact trap is LeetCode 577 (Employee
Bonus).

## Common Pitfalls

- **`= NULL` / `!= NULL` never match anything.** Only `IS NULL` / `IS NOT NULL`
  work.
- **`NOT IN` with a NULL in the list returns zero rows.**
  `x NOT IN (1, 2, NULL)` → `x<>1 AND x<>2 AND x<>NULL` → the last term is
  UNKNOWN → the whole predicate can never be TRUE. The most commonly-exploited
  SQL interview gotcha. *(Full treatment in [03 — Anti-Joins](./03-anti-joins-not-in-not-exists.md).)*
- **`BETWEEN` on timestamps.** `BETWEEN '2023-01-01' AND '2023-12-31'` silently
  excludes everything on Dec 31 after `00:00:00`, because the upper bound is
  midnight. Use half-open ranges instead: `>= '2023-01-01' AND < '2024-01-01'`.
- **`NOT (x = 5)` vs `x <> 5`** — identical, and if `x` is NULL **both** drop
  the row. Negation doesn't rescue NULLs.
- **Leading-wildcard `LIKE '%foo'` can't use a B-tree index** → full scan. File
  for Phase 7.
- **Aggregates skip NULLs** (`COUNT(bonus)` ≠ `COUNT(*)`) — same root cause, see
  [04 — Aggregates](./04-aggregate-functions.md).

## Interview Framing

Two questions you should answer cold:

> **"Difference between `NOT IN` and `NOT EXISTS`?"**
> Answer with the NULL semantics, not "one's a subquery." `NOT IN` returns no
> rows if the subquery yields any NULL; `NOT EXISTS` is NULL-safe and usually
> optimizes to an anti-join. Senior addition: *"So I default to `NOT EXISTS`
> unless the column is provably `NOT NULL`."*

> **"Find rows where two columns differ, including when one is NULL."**
> `a IS DISTINCT FROM b`. Naming it wins the point.

Proactively stating *"I'm assuming `bonus` is nullable, so I'll handle that"*
**before** writing the query is the senior-vs-mid signal.

## Related Real-World Application

NULL semantics are identical in Spark SQL / Databricks (ANSI three-valued
logic). The `NOT IN` trap is *worse* at scale: Catalyst can't rewrite `NOT IN`
into a broadcast anti-join when nullability is unknown, so it falls back to a
slow shuffle. `NOT EXISTS` / `LEFT ANTI JOIN` is both correct and faster. Spark's
null-safe equality operator is `<=>` (equivalent to `IS NOT DISTINCT FROM`) —
the one you reach for in `MERGE` conditions on nullable business keys, directly
relevant to Phase 9 SCD2 work.

---

[← Prev: SELECT/WHERE/ORDER BY/LIMIT](./01-select-where-orderby-limit.md) | [Next: Anti-Joins →](./03-anti-joins-not-in-not-exists.md)
