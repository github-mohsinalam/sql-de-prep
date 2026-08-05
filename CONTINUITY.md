# CONTINUITY

Cross-chat tracker for the SQL prep roadmap. Update at the **end of each phase**
before starting a new chat. Lives at repo top level, alongside the roadmap.

---

## Current status

- **Phase 1 (Foundations Refresher): COMPLETE** ✅
- **Next action:** start **Phase 2 — Joins & Set Operations** in a fresh chat.
- Pace: 30–45 min/day. Approach: learn one concept at a time → practice → notes
  and solutions consolidated at phase end (not mid-phase).

## Repo structure (per phase)

```
phase-NN-name/
├── README.md              # phase index (links notes + problems + solutions)
├── notes/                 # one file per concept, numbered, cross-linked
│   └── NN-concept.md
├── problems/
│   └── problems.md        # all problem statements + schema, one file
└── solutions/             # TOP-LEVEL, sibling of problems/ (NOT nested inside)
    └── NNN-problem.sql    # one file per solution
```

Conventions settled in Phase 1:
- Per-concept note files (not one big notes.md), numbered `01-`, `02-`, …, with
  `[← Prev | Next →]` footer nav; last note links back to phase `README.md`.
- Note template (flexible): Concept Overview → Key Syntax → Worked Example →
  Common Pitfalls → Interview Framing → Related Real-World Application. Adapt
  when a topic doesn't fit (e.g. the anti-join deep dive used problem → solutions
  → traps instead).
- Practice write-ups: **question visible, solution below** in a `## Solutions`
  section at the bottom of the doc. **No `<details>` collapsibles** — they don't
  render in the file preview surfaces used; plain markdown only.
- Solution `.sql` files: final accepted query + a **lean** comment header. Only
  genuinely non-obvious insight — no restating what the query plainly does.

## Workflow (agreed)

1. Concepts one at a time in-chat; user asks follow-ups mid-concept to solidify.
2. User validates against a **local Postgres** seeded with real tables + edge
   cases before submitting.
3. Practice problems attempted by user first (no solution upfront), then
   reviewed for correctness **and** style/performance, then submitted on
   LeetCode for the "Accepted" checkpoint.
4. At phase end: generate note files, problems.md, solution files, phase
   README, and update this tracker.

---

## Phase 1 — what was covered

**Concepts (6):** SELECT/WHERE/ORDER BY/LIMIT (logical execution order) ·
filtering IN/BETWEEN/LIKE/NULL (three-valued logic) · anti-joins deep dive
(NOT IN vs NOT EXISTS vs LEFT ANTI JOIN) · aggregates COUNT/SUM/AVG/MIN/MAX ·
GROUP BY/HAVING · DISTINCT.

**Problems (7, all Accepted):** 595, 620, 1873, 182, 183, 181, 176.

**Key learnings carried forward:**
- Three-valued logic underlies most NULL behavior; state nullability assumptions
  out loud.
- `NOT EXISTS` is the default anti-join (NULL-safe, compiles to anti-join);
  `NOT IN` has two independent NULL failure modes (list-side poisoning,
  outer-side exclusion).
- `LEFT JOIN` + `WHERE` on the right table's column = accidental inner join.
- Scalar subquery in SELECT-list returns NULL on empty (the 176 trick).
- Sargability + WHERE-before-HAVING both preview Phase 7.

## Deferred items (revisit in later phases)

| Topic | Trigger | Target phase |
|---|---|---|
| Index scan mechanics vs. `WHERE` predicates — B-tree seek/range, `=` vs range vs `OR`-across-columns, `LIKE 'x%'` vs `'%x'`, sargability (functions on columns), composite-index leftmost-prefix rule, bitmap-OR, index-only scans, when a scan beats an index | LC 595 `OR`-across-columns → `UNION` rewrite; recurred in 1873 (`LIKE 'M%'`) | **Phase 7** |

*(A short crisp version of the index mechanism was given in-chat; the full
treatment — cost estimation, bitmap scans, index-only scans — is deferred to
Phase 7.)*

---

## Local Postgres state (seeded, reusable)

Tables currently seeded for hands-on practice:

- **`employee`** — `id, name, salary, department_id, manager_id, bonus`. Salary
  `NOT NULL` was **dropped** (nullable now) to test NULL-skip. 11 rows with:
  NULL salary (Grace), NULL dept+manager (Ivan), salary tie (Bob/Carol 90k),
  employee > manager (Dave>Bob), duplicate name (two 'Alice'), 3 NULL bonuses,
  bonus tie (Bob/Carol 8k). 2-level manager tree.
- **`department`** — `id, name`. ids realigned to **10/20/30** (IT/Sales/
  Marketing) to match employee refs, plus **40 Finance** (deliberately empty,
  for LEFT/anti-join). Optional FK `fk_emp_dept` available.
- **`customers_dd` / `orders_dd`** — anti-join deep-dive tables; `orders_dd` has
  a NULL-customer order (104) and a referential-orphan order (105, customer 99).
- **`emp_agg`** — aggregate practice (nullable dept + bonus).

> Consider committing these seeds to `postgres-setup/` so every solution in the
> repo is runnable against real edge-case data.

## Next chat: Phase 2 — Joins & Set Operations

Concepts: INNER/LEFT/RIGHT/FULL/CROSS/SELF joins, anti-joins
(NOT EXISTS / LEFT JOIN…IS NULL — already deep-dived, will connect), UNION/
UNION ALL/INTERSECT/EXCEPT, multi-table joins.

Problems: 175, 197, 577, 584, 1068, 1084, 1795, 1581, 1097 (pick a few of the
Game Play Analysis series).
