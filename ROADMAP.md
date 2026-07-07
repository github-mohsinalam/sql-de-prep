# SQL Roadmap: Data Engineer → Senior Data Engineer Interview Prep

**Profile:** Data Engineer (Azure/Databricks/PySpark), rusty on SQL (know basics/joins/aggregations/CTAs/window functions but haven't used in ~2 years)
**Pace:** 30–45 min/day
**Timeline:** Open-ended, targeting interview-readiness in ~2 months, continued polish after
**Total duration:** ~12–14 weeks (this will move faster than a true beginner since you're refreshing, not learning from zero — expect to compress Phases 1–3)

---

## How this roadmap is structured

Each phase has: **concepts to (re)learn**, **hands-on practice**, **LeetCode/practice-site problems**, and **time estimate**. Daily split at 30–45 min: ~15 min concept review, ~20–30 min problem-solving. Practice > reading — don't linger on theory once a concept clicks.

**Primary practice sources:**
- **LeetCode SQL 50** (curated study plan — the backbone of this roadmap)
- **StrataScratch** (real company interview questions, great for DE-flavored questions)
- **DataLemur** (SQL + analytics interview questions, good explanations)
- **Mode SQL Tutorial** (free, good for concept refreshers)

---

## Phase 0: Setup (Day 1, ~30 min)

- Pick your practice environment: LeetCode's built-in editor is enough to start. Optionally set up a local Postgres or use Databricks SQL warehouse (free edition) since that's your actual work environment — this doubles as portfolio-relevant practice.
- Create a tracker (spreadsheet or Notion) with columns: Problem | Topic | Difficulty | Attempts | Solved? | Notes/Pattern learned. This becomes gold for your final review week.

---

## Phase 1: Foundations Refresher — 4–5 days

**Concepts:** SELECT/WHERE/ORDER BY/LIMIT, filtering (IN, BETWEEN, LIKE, NULL handling), basic aggregate functions (COUNT, SUM, AVG, MIN, MAX), GROUP BY/HAVING, DISTINCT.

**Practice (LeetCode SQL 50 — "Select" & "Basic Joins" intro problems):**
- 176. Second Highest Salary
- 181. Employees Earning More Than Their Managers
- 182. Duplicate Emails
- 183. Customers Who Never Order
- 595. Big Countries
- 620. Not Boring Movies
- 1873. Calculate Special Bonus

**Time:** ~4–5 days (this should feel fast — it's a refresher)

---

## Phase 2: Joins & Set Operations — 5–6 days

**Concepts:** INNER/LEFT/RIGHT/FULL/CROSS/SELF joins, anti-joins (NOT EXISTS/LEFT JOIN...IS NULL pattern), UNION/UNION ALL/INTERSECT/EXCEPT, multi-table joins.

**Practice:**
- 175. Combine Two Tables
- 197. Rising Temperature
- 577. Employee Bonus
- 584. Find Customer Referee
- 1068. Product Sales Analysis I
- 1084. Sales Analysis III
- 1795. Rearrange Products Table
- 1581. Customer Who Visited but Did Not Make Any Transactions (anti-join pattern — very common interview ask)
- 1097. Game Play Analysis (I–V, pick a few)

**Time:** ~5–6 days

---

## Phase 3: Subqueries & Aggregation Depth — 4–5 days

**Concepts:** Correlated vs non-correlated subqueries, subqueries in SELECT/WHERE/FROM, HAVING vs WHERE nuances, GROUP BY with multiple columns, ROLLUP/CUBE (if your DB supports it).

**Practice:**
- 626. Exchange Seats
- 1050. Actors and Directors Who Cooperated at Least Three Times
- 1633. Percentage of Users Attended a Contest
- 1341. Movie Rating
- 570. Managers with at Least 5 Direct Reports
- 1729. Find Followers Count

**Time:** ~4–5 days

---

## Phase 4: Window Functions Deep Dive — 8–10 days

This is the single highest-leverage topic for both LeetCode-style interviews and real DE work (dedup, ranking, running totals, gap/island problems). Given you've used window functions before, this phase is about going deep, not just re-learning syntax.

**Concepts:** ROW_NUMBER, RANK, DENSE_RANK, NTILE, LAG/LEAD, FIRST_VALUE/LAST_VALUE, running totals (SUM/AVG OVER), frame clauses (ROWS/RANGE BETWEEN), PARTITION BY nuances, deduplication patterns, gaps-and-islands problems.

**Practice:**
- 177. Nth Highest Salary
- 178. Rank Scores
- 184. Department Highest Salary
- 185. Department Top Three Salaries (classic hard window-function question — expect this or a variant in senior interviews)
- 1069. Product Sales Analysis II
- 1907. Count Salary Categories
- 2004. The Number of Seniors and Juniors to Join the Company
- 1454. Active Users
- 1077. Project Employees III
- 1596. The Most Frequently Ordered Products for Each Customer
- StrataScratch: search "running total," "consecutive days," "gaps and islands" — these show up often at DE-heavy companies (Amazon, Uber, Airbnb)

**Time:** ~8–10 days (don't rush this — it's the topic most likely to separate mid from senior candidates)

---

## Phase 5: CTEs & Recursive Queries — 4–5 days

**Concepts:** WITH clauses, chaining multiple CTEs, recursive CTEs (hierarchies, org charts, date series generation), when to use CTE vs subquery vs temp table.

**Practice:**
- 262. Trips and Users
- 1provide: 1264/1270 style hierarchy problems (search "employee hierarchy" on LeetCode/StrataScratch)
- Build a recursive CTE yourself: generate a date series for the last 30 days (extremely common real-world DE pattern, also occasionally asked directly)
- 1204. Last Person to Fit in the Bus (running total + CTE)

**Time:** ~4–5 days

---

## Phase 6: String, Date & Conditional Logic — 4–5 days

**Concepts:** CASE WHEN (including pivot-style aggregation), date/time functions (DATEDIFF, DATE_TRUNC, EXTRACT), string functions (SUBSTRING, CONCAT, SPLIT, REGEXP), NULL-safe comparisons (COALESCE, NULLIF).

**Practice:**
- 1179. Reformat Department Table (pivot pattern)
- 1211. Queries Quality and Percentage
- 1327. List the Products Ordered in a Period
- 1683. Invalid Tweets
- 176-series date problems: 1965, 2356 (search "date" tag on LeetCode SQL)
- Practice writing one pivot query and one unpivot query manually (very commonly asked to "explain how you'd do this without PIVOT")

**Time:** ~4–5 days

---

## Phase 7: Query Performance & Execution — 6–7 days *(Senior-level differentiator #1)*

This is where junior/mid candidates fall short. Senior DE interviews expect you to reason about *how* a query runs, not just get the right output.

**Concepts:**
- Execution plans (EXPLAIN / EXPLAIN ANALYZE) — read and reason about plans
- Indexing: B-tree vs columnar, when indexes help/hurt, composite index column order
- Join algorithms: nested loop, hash join, merge join — when the optimizer picks each
- Partitioning & clustering (especially relevant to your Databricks/Spark background — connect to Delta Lake Z-ordering/partition pruning)
- Query rewriting for performance (avoiding SELECT *, predicate pushdown, avoiding correlated subqueries in hot paths)
- Statistics and cardinality estimation (conceptual level)

**Practice:** Fewer LeetCode problems here — instead:
- Take 3–4 of your Phase 4/5 solutions and run EXPLAIN on them (Postgres or Databricks SQL); interpret the plan
- Read Databricks docs on Photon/Delta optimization (directly reusable for your actual job + interviews)
- Practice articulating out loud: "How would you optimize this slow query?" for 2–3 sample scenarios

**Time:** ~6–7 days

---

## Phase 8: Database Design & Transactions — 5–6 days *(Senior-level differentiator #2)*

**Concepts:** Normalization (1NF–3NF, when to denormalize), primary/foreign keys, ACID properties, transaction isolation levels (Read Committed, Repeatable Read, Serializable) and what anomalies each prevents (dirty read, non-repeatable read, phantom read), optimistic vs pessimistic locking, deadlocks.

**Practice:**
- No LeetCode here (this is conceptual/discussion-based) — instead write short explanations in your own words for each isolation level with an example scenario
- Design exercise: sketch a normalized schema for an e-commerce orders system, then explain a scenario where you'd deliberately denormalize (this is a very common senior DE interview question)

**Time:** ~5–6 days

---

## Phase 9: Data Warehousing & Dimensional Modeling — 5–6 days *(Directly relevant to your DE work)*

**Concepts:** Star vs snowflake schema, fact vs dimension tables, Slowly Changing Dimensions (SCD Type 1/2/3), grain, surrogate keys, fact table types (transactional, periodic snapshot, accumulating snapshot).

**Practice:**
- Write a SQL pattern for implementing SCD Type 2 (very commonly asked — "write a query to handle SCD2 updates")
- StrataScratch has several dimensional-modeling-flavored questions — search "SCD" or "warehouse"
- Map this back to your Nielsen pipeline work — you likely already have real examples; prepare 1–2 as talking points

**Time:** ~5–6 days

---

## Phase 10: Spark SQL / Distributed SQL Nuances — 4–5 days *(Your edge — lean into it)*

Since you already work in Databricks, this phase is lower-effort but high-payoff — senior DE interviews at companies using Spark will probe this directly.

**Concepts:** How Spark SQL execution differs from traditional RDBMS (lazy evaluation, Catalyst optimizer, shuffle), broadcast joins vs shuffle joins, partition pruning, Delta Lake MERGE/UPSERT syntax, handling skew.

**Practice:**
- Rewrite 3–5 of your earlier window-function/CTE solutions as Spark SQL in a Databricks notebook
- Practice explaining broadcast join vs shuffle join trade-offs out loud
- Write a MERGE INTO statement for an upsert scenario (directly reusable from your DAB/pipeline work)

**Time:** ~4–5 days

---

## Phase 11: Mixed Practice & Timed Drills — ongoing + dedicated 2 weeks near the end

- Weeks 1–10 (above): do 1–2 problems/day as you go
- Final 2 weeks before you start interviewing: shift to **timed, mixed-topic drills** — pick 3 random problems spanning different phases, solve each in 15–20 min without looking at notes
- Revisit your tracker: redo every problem you marked "struggled" or took 2+ attempts
- Do at least 5–6 StrataScratch "company-tagged" problems (e.g., Amazon, Meta, Uber SQL questions) to calibrate to real interview difficulty

**Time:** ~2 weeks dedicated, woven throughout otherwise

---

## Phase 12: Mock Interviews & Communication — 3–4 days (last week before interviews start)

Senior interviews weight *how* you talk through a query as much as the answer.

- Practice narrating your approach before writing SQL: clarify requirements, state assumptions about NULLs/duplicates, outline the query structure, then write it
- Prepare 2–3 STAR-format stories from your Nielsen/DAB work that show query optimization or debugging judgment — bridges nicely into "tell me about a time you optimized a slow query" style questions
- If possible, do 1 mock interview (peer, or talk-aloud solo with a timer) per remaining problem type

---

## Suggested Week-by-Week Pacing (30–45 min/day)

| Weeks | Phase |
|---|---|
| 1 | Phase 1 + start Phase 2 |
| 2 | Finish Phase 2 + Phase 3 |
| 3–4 | Phase 4 (Window Functions) |
| 5 | Phase 5 (CTEs) |
| 6 | Phase 6 (String/Date/CASE) |
| 7–8 | Phase 7 (Performance) |
| 9 | Phase 8 (DB Design/Transactions) |
| 10 | Phase 9 (Dimensional Modeling) |
| 11 | Phase 10 (Spark SQL) |
| 12–13 | Phase 11 (Mixed timed drills) |
| 14 | Phase 12 (Mock interviews, before you start applying) |

~14 weeks at your pace — but since you're refreshing rather than learning from zero, Phases 1–3 will likely compress, giving you buffer room for Phase 4 and 7 (the two hardest, highest-payoff phases).

---

## Milestone Checkpoints

- [ ] End of Week 2: Can write any join type from memory without looking up syntax
- [ ] End of Week 4: Can solve a "Nth highest per group" window function problem in under 10 min
- [ ] End of Week 6: Can write a recursive CTE and a pivot query unaided
- [ ] End of Week 8: Can read an EXPLAIN plan and identify the join strategy used
- [ ] End of Week 10: Can explain SCD Type 2 and write the MERGE logic for it
- [ ] End of Week 12: Can solve 3 mixed-topic problems in 45 min under time pressure
- [ ] End of Week 14: Comfortable narrating query-writing thought process out loud

---

## Notes for the Claude Project

When you set up the Project, useful standing chats might be:
1. **Concept explainer** — deep dives on each phase's topics, calibrated to your DE background
2. **Problem review** — paste your LeetCode/StrataScratch attempts for feedback on correctness *and* style/performance
3. **Mock interview partner** — verbal walk-throughs, follow-up questions like a real interviewer would ask
4. **Progress tracker** — log what's done, get spaced-repetition review suggestions on weak topics
