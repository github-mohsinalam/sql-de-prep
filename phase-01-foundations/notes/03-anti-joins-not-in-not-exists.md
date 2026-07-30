# 03 — Anti-Joins: NOT IN vs NOT EXISTS vs LEFT ANTI JOIN

> Phase 1: Foundations Refresher — deep dive
>
> Prereq: three-valued logic from [02 — Filtering](./02-filtering-in-between-like-null.md).

All four idioms below express the **same relational operation**: the anti-join
(`R ▷ S`) — *"rows of R with no matching row in S."* They are **not**
interchangeable once NULLs are involved. This note is about exactly how and why
they diverge.

---

## Setup

```sql
DROP TABLE IF EXISTS orders_dd, customers_dd;

CREATE TABLE customers_dd (
    customer_id INT PRIMARY KEY,
    name        TEXT
);

CREATE TABLE orders_dd (
    order_id    INT PRIMARY KEY,
    customer_id INT,          -- deliberately NULLABLE
    amount      NUMERIC
);

INSERT INTO customers_dd VALUES
    (1, 'Alice'), (2, 'Bob'), (3, 'Carol'), (4, 'Dave');

INSERT INTO orders_dd VALUES
    (101, 1,    250),
    (102, 1,    100),
    (103, 2,    400),
    (104, NULL, 999);   -- an orphaned / unattributed order
```

**Question:** which customers have never ordered? By eye: **Carol (3), Dave (4).**

---

## The four ways to write it

### 1. `NOT IN` — the broken one

```sql
SELECT name
FROM   customers_dd
WHERE  customer_id NOT IN (SELECT customer_id FROM orders_dd);
```

**Returns zero rows.** No error. The subquery returns `{1, 1, 2, NULL}`; for
Carol the predicate unfolds to
`3<>1 AND 3<>1 AND 3<>2 AND 3<>NULL` → `TRUE AND TRUE AND TRUE AND UNKNOWN` →
**UNKNOWN** → row dropped. A single NULL anywhere in the list annihilates the
entire result set. The mandatory guard:

```sql
WHERE customer_id NOT IN (
    SELECT customer_id FROM orders_dd WHERE customer_id IS NOT NULL
);
```

### 2. `NOT EXISTS` — the correct default

```sql
SELECT c.name
FROM   customers_dd c
WHERE  NOT EXISTS (
    SELECT 1
    FROM   orders_dd o
    WHERE  o.customer_id = c.customer_id
);
```

→ Carol, Dave. ✅ `EXISTS` asks only *"did the correlated subquery return ≥1
row?"* — a pure boolean, no three-valued logic. A NULL simply fails to match
(quietly, locally) instead of poisoning the whole predicate.

### 3. `LEFT JOIN ... IS NULL` — the anti-join by hand

```sql
SELECT c.name
FROM       customers_dd c
LEFT JOIN  orders_dd    o ON o.customer_id = c.customer_id
WHERE      o.order_id IS NULL;   -- check a NOT NULL column of the right table
```

→ Carol, Dave. ✅ Keeps all customers, pads right-side columns with NULL where
no match, then keeps only the padded rows. Use this form when you also need
right-table columns elsewhere in the query.

> **Correctness caveat:** this works *only* because `order_id` is the PK and
> therefore `NOT NULL`. Null-check a **nullable** right column (e.g. `o.amount`)
> and you can no longer distinguish "no match" from "matched but the column was
> NULL" — the query silently breaks. `NOT EXISTS` has no such footgun.

### 4. `EXCEPT` — the set-based one

```sql
SELECT customer_id FROM customers_dd
EXCEPT
SELECT customer_id FROM orders_dd;
```

→ 3, 4. ✅ NULL-safe (set operators use `IS NOT DISTINCT FROM` semantics —
NULL *does* match NULL here). But it dedups, compares only the projected
columns, and can't return `name` without a rejoin. Fine for simple key diffs.

---

## Translating `NOT IN` → `NOT EXISTS`

`NOT EXISTS` applies to the **subquery form**, not a literal list. Three
mechanical moves:

```sql
-- NOT IN form
WHERE o.x NOT IN (SELECT i.y FROM inner_t i);

-- NOT EXISTS form
WHERE NOT EXISTS (
    SELECT 1                 -- (1) projection becomes irrelevant; 1 is idiomatic
    FROM   inner_t i
    WHERE  i.y = o.x         -- (2) the IN-column becomes a correlated equality
);                           -- (3) NOT IN → NOT EXISTS
```

The subquery's column moves **out** of the projection and **into** a correlated
`WHERE i.y = o.x`. `SELECT 1` is a throwaway — `EXISTS` never looks at *what*
came back, only *whether* anything did.

---

## Two independent NULL problems (do not conflate)

A NULL in `x NOT IN (subquery)` can live in two places, causing two unrelated
problems:

| | Where | Effect | Fix |
|---|---|---|---|
| **List-side** | NULL *inside* the subquery result | Poisons **every** row → zero rows | Remove it from the list (`WHERE col IS NOT NULL`), or use `NOT EXISTS` |
| **Outer-side** | `x` itself is NULL | Drops **only that row** | Design decision — see table below |

Guarding the outer value (`x IS NOT NULL AND ...`, or `COALESCE(x, sentinel)`)
does **nothing** about list-side poison — the poison is `x <> NULL` *in the
list*, which no amount of coalescing `x` reaches. The only fix for a list-side
NULL is to remove it from the list.

> Sentinel caveat: `COALESCE(x, -1) NOT IN (...)` only "works" if the sentinel
> isn't itself in the exclusion set, and wrapping the column in `COALESCE` kills
> index usage on `x`.

---

## How the four behave on a NULL *outer* key

The "safe" forms are **not** perfectly interchangeable — they diverge here:

| Outer key is NULL | Behavior |
|---|---|
| `NOT IN` | `NULL NOT IN (...)` → UNKNOWN → row **excluded** |
| `NOT EXISTS` | `NULL = anything` never TRUE → no match → row **included** |
| `LEFT JOIN ... IS NULL` | join never matches → row **included** |
| `EXCEPT` | NULL matches NULL on the right if present → **depends** |

`NOT EXISTS` and `LEFT JOIN...IS NULL` agree; `NOT IN` and `EXCEPT` each go their
own way. **Rule to carry:** default to `NOT EXISTS`; use `LEFT JOIN...IS NULL`
when you need right-side columns; use `NOT IN` only against a provably `NOT NULL`
column — and say *why* out loud.

---

## What `EXPLAIN` actually showed (measured, not assumed)

On a local Postgres, after `ANALYZE customers_dd; ANALYZE orders_dd;`:

**`NOT EXISTS`** →
```
Hash Right Anti Join  (rows=1)
  Hash Cond: (o.customer_id = c.customer_id)
```

**`LEFT JOIN ... IS NULL`** →
```
Hash Right Join  (rows=1)
  Hash Cond: (o.customer_id = c.customer_id)
  Filter: (o.order_id IS NULL)
```

**Key finding — they did *not* compile to the same operator.** `NOT EXISTS`
got a true `Anti Join`; `LEFT JOIN...IS NULL` got a plain join **plus a separate
`Filter`** that discards the matched rows afterward. So the common claim "both
always become the same anti-join plan" is **false** in general — it's
version/planner-dependent. `NOT EXISTS` is the more dependable path to the
anti-join operator.

`NOT IN` (for contrast) produces neither — typically a `Filter` with a hashed
`SubPlan`, because the NULL semantics forbid the anti-join rewrite unless the
column is provably `NOT NULL`. So `NOT IN` is a correctness hazard *and* a
performance hazard, for the same underlying reason.

Notes on reading the plan:
- **`cost=startup..total`** — startup = work before the first row (building the
  hash table); total = all rows. Compare *total* unless you care about
  time-to-first-row (`LIMIT` queries).
- Estimates only become meaningful after `ANALYZE` — before it, Postgres uses
  hardcoded fallbacks (`rows=1200` etc.). `EXPLAIN (ANALYZE, BUFFERS)` runs the
  query and prints **actual** vs **estimated** rows; the gap between them is the
  core Phase 7 diagnostic (stale stats → wrong estimate → wrong plan).
- A `Filter` doing work a smarter operator could avoid is a rewrite signal.

---

## Practice

Three problems, all run against the
`customers_dd` / `orders_dd` setup at the top of this file. **Attempt each
before scrolling to [Solutions](#solutions) at the bottom of the doc.**

**Problem A**

> Rewrite the `NOT EXISTS` query as `LEFT JOIN...IS NULL`, then `EXPLAIN` both.
> Tell the difference in the query plan.

**Problem B**

> Find customers who have **no order over 300**. Careful: this is *not* the same
> as "customers whose orders are all ≤ 300." Alice (250, 100) qualifies. Write
> it with `NOT EXISTS`. Then try it with `NOT IN` and notice whether the NULL
> order breaks it — and *why or why not* .

**Problem C**

> Now flip it: find every order whose `customer_id` doesn't correspond to a real
> customer — i.e. orphaned orders. Does order 104 (the NULL one) show up in your
> result? Should it? Defend whichever answer you give.

## Interview one-liner

> "`NOT EXISTS` is my default anti-join. `NOT IN` is a NULL trap — one NULL in
> the subquery drops every row, and the optimizer can't rewrite it as an
> anti-join. `LEFT JOIN...IS NULL` works when I null-check a `NOT NULL` column
> and want right-side columns anyway."

## Related Real-World Application

Spark SQL exposes the operation directly as `LEFT ANTI JOIN`:

```sql
SELECT c.name
FROM   customers_dd c
LEFT ANTI JOIN orders_dd o ON o.customer_id = c.customer_id;
```

Same semantics as `NOT EXISTS`, and the phrasing the Catalyst optimizer prefers.
`NOT IN` on a nullable column blocks the broadcast-anti-join rewrite and forces a
shuffle — correctness *and* performance both argue for `NOT EXISTS` /
`LEFT ANTI JOIN` at scale.

---

## Solutions

*Attempt the [Practice](#practice) problems above before reading.*

### Solution A

```sql
-- NOT EXISTS form
SELECT c.name
FROM   customers_dd c
WHERE  NOT EXISTS (SELECT 1 FROM orders_dd o WHERE o.customer_id = c.customer_id);

-- LEFT JOIN ... IS NULL form (equivalent output: Carol, Dave)
SELECT c.name
FROM       customers_dd c
LEFT JOIN  orders_dd    o ON o.customer_id = c.customer_id
WHERE      o.order_id IS NULL;
```

Both return **Carol, Dave**. But after `ANALYZE`, the plans differ:
`NOT EXISTS` → `Hash Right Anti Join`; `LEFT JOIN...IS NULL` →
`Hash Right Join` + a separate `Filter: (o.order_id IS NULL)`. **They do not
compile to the same operator** — the anti-join does it in one step, the
left-join materializes all matches then filters. So the expectation baked into
the question ("identical operator") turned out to be wrong on this Postgres, and
that's the lesson: `NOT EXISTS` is the more dependable path to the anti-join.
(Full plans in the *What EXPLAIN actually showed* section above.)

### Solution B

```sql
-- Correct: NOT EXISTS, with amount > 300 INSIDE the correlated subquery
SELECT name
FROM   customers_dd c
WHERE  NOT EXISTS (
    SELECT 1
    FROM   orders_dd o
    WHERE  o.customer_id = c.customer_id
      AND  o.amount > 300
);
-- → Alice (250,100), Carol (none), Dave (none). Bob excluded (has 400).
```

The `amount > 300` predicate must live **inside** the subquery, next to the
correlation — the question is "does there exist an order that is *both* this
customer's *and* over 300?" Pulling `amount` to the top level won't even compile
(it's not a column of `customers_dd`).

```sql
-- NOT IN version — BREAKS (returns zero rows)
SELECT name
FROM   customers_dd c
WHERE  c.customer_id NOT IN (
    SELECT customer_id FROM orders_dd WHERE amount > 300
);
```

Why it breaks: the subquery filters to orders over 300. The NULL-customer order
has `amount = 999 > 300`, so it **passes the filter**, and its NULL
`customer_id` enters the list → `{2, NULL}` → poison → zero rows. The subtle
lesson: **whether `NOT IN` breaks depends on the subquery's own `WHERE`, not
just the table.** Filter `amount < 100` instead and the NULL order is excluded,
the list is clean, and `NOT IN` accidentally works — same tables, different
filter, different correctness.

### Solution C

```sql
-- Catches BOTH orphan categories
SELECT order_id
FROM   orders_dd o
WHERE  NOT EXISTS (
    SELECT 1
    FROM   customers_dd c
    WHERE  o.customer_id = c.customer_id
);
```

Two categories of orphan: **(1)** `customer_id IS NULL` (unattributed — order
104), and **(2)** a real integer matching no customer (insert `(105, 99, 500)`
to test — customer 99 doesn't exist). `NOT EXISTS` catches both: for 104,
`NULL = c.customer_id` is UNKNOWN for every customer → no match → included
(outer-NULL semantics); for 105, `99 = c.customer_id` is a clean FALSE for every
customer → no match → included.

**Should 104 be there?** Business decision, not a SQL fact. 105 is an
unambiguous referential-integrity violation. 104 has *no* customer at all —
could be a legitimate guest/cash sale, not an "orphan." Flag the assumption. To
report referential violations only:

```sql
SELECT order_id
FROM   orders_dd o
WHERE  o.customer_id IS NOT NULL           -- exclude the unattributed
  AND  NOT EXISTS (SELECT 1 FROM customers_dd c
                   WHERE c.customer_id = o.customer_id);
-- → 105 only
```

---

[← Prev: Filtering](./02-filtering-in-between-like-null.md) | [Next: Aggregate Functions →](./04-aggregate-functions.md)
