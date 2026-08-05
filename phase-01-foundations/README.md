# Phase 1 — Foundations Refresher

SQL prep roadmap, Phase 1. Covers the core single-table toolkit: projection,
filtering, three-valued logic, aggregation, grouping, and dedup. **Status:
complete.**

## Concepts

Notes are in [`notes/`](./notes), one file per concept, cross-linked in order.

| # | Concept | Note |
|---|---|---|
| 01 | SELECT / WHERE / ORDER BY / LIMIT — logical execution order | [md](./notes/01-select-where-orderby-limit.md) |
| 02 | Filtering: IN / BETWEEN / LIKE / NULL — three-valued logic | [md](./notes/02-filtering-in-between-like-null.md) |
| 03 | Anti-joins: NOT IN vs NOT EXISTS vs LEFT ANTI JOIN *(deep dive)* | [md](./notes/03-anti-joins-not-in-not-exists.md) |
| 04 | Aggregate functions: COUNT / SUM / AVG / MIN / MAX | [md](./notes/04-aggregate-functions.md) |
| 05 | GROUP BY / HAVING — rows vs groups | [md](./notes/05-group-by-having.md) |
| 06 | DISTINCT | [md](./notes/06-distinct.md) |

## Problems

Statements consolidated in [`problems/problems.md`](./problems/problems.md);
solutions in [`problems/solutions/`](./solutions), one `.sql` per
problem. All 7 accepted on LeetCode.

| # | Problem | Difficulty | Pattern |
|---|---|---|---|
| 595 | Big Countries | Easy | `WHERE` / `OR` |
| 620 | Not Boring Movies | Easy | modulo + NULL-safe compare |
| 1873 | Calculate Special Bonus | Easy | `CASE`, sargable `LIKE` |
| 182 | Duplicate Emails | Easy | `GROUP BY … HAVING` |
| 183 | Customers Who Never Order | Easy | anti-join (`NOT EXISTS`) |
| 181 | Employees Earning More Than Their Managers | Easy | self-join |
| 176 | Second Highest Salary | Medium | scalar subquery → NULL on empty |

## Recurring threads

A few ideas showed up across multiple concepts and are worth carrying forward:

- **Three-valued logic (TRUE / FALSE / UNKNOWN)** underlies the `NOT IN` trap,
  the `!=` vs `IS DISTINCT FROM` choice, aggregate NULL-skipping, and
  CASE-routing-UNKNOWN-to-ELSE. State nullability assumptions out loud.
- **`NOT EXISTS` as the default anti-join** — NULL-safe and reliably compiled to
  an anti-join, unlike `NOT IN`.
- **Sargability** (`LIKE 'x%'` vs `%x`, bare column vs wrapped) and
  **`WHERE`-before-`HAVING`** filtering both preview Phase 7 (performance).

## Deferred to later phases

See [`../CONTINUITY.md`](../CONTINUITY.md) for the running deferred list. Phase 1
logged one item: **index scan mechanics vs. `WHERE` predicates** (full treatment
in Phase 7).
