# SQL Senior Data Engineer Interview Prep

A structured, phase-by-phase journey from rusty SQL fundamentals to senior-level interview readiness — notes, worked examples, and solved practice problems, built while preparing for Senior Data Engineer interviews.

**Background:** Written from the perspective of a working Data Engineer (Azure/Databricks/PySpark) refreshing SQL fundamentals and building up to senior-level topics: query performance, database design, dimensional modeling, and Spark SQL nuances.

If you're a fellow data engineer prepping for interviews, feel free to use this as a study reference.

---

## Roadmap

| Phase | Topic | Status |
|---|---|---|
| [01](phase-01-foundations/) | Foundations Refresher | 🔲 Not started |
| [02](phase-02-joins-set-ops/) | Joins & Set Operations | 🔲 Not started |
| [03](phase-03-subqueries-aggregation/) | Subqueries & Aggregation Depth | 🔲 Not started |
| [04](phase-04-window-functions/) | Window Functions Deep Dive | 🔲 Not started |
| [05](phase-05-ctes-recursive/) | CTEs & Recursive Queries | 🔲 Not started |
| [06](phase-06-string-date-conditional/) | String, Date & Conditional Logic | 🔲 Not started |
| [07](phase-07-query-performance/) | Query Performance & Execution | 🔲 Not started |
| [08](phase-08-db-design-transactions/) | Database Design & Transactions | 🔲 Not started |
| [09](phase-09-dimensional-modeling/) | Data Warehousing & Dimensional Modeling | 🔲 Not started |
| [10](phase-10-spark-sql/) | Spark SQL / Distributed SQL Nuances | 🔲 Not started |
| [11](phase-11-mixed-timed-drills/) | Mixed Practice & Timed Drills | 🔲 Not started |
| [12](phase-12-mock-interviews/) | Mock Interviews & Communication | 🔲 Not started |

Update the status column as you progress: 🔲 Not started → 🟡 In progress → ✅ Done

## Structure

Each `phase-XX-*/` folder contains:
- **notes.md** — concept explanation (written up after the Claude Project chat for that phase)
- **problems/** — solved practice problems, one `.sql` file per problem, with a header comment linking the source

## Local Practice Environment

See [`postgres-setup/`](postgres-setup/) for a Docker-based local Postgres environment with seed data matching common LeetCode SQL problems (employee/department tables etc.), so you can run and test queries locally instead of only in the LeetCode editor.

## Why this exists

Most SQL interview prep is either pure LeetCode grinding (no depth on *why*) or textbook theory (no practice). This repo tries to pair both, phase by phase, with a bias toward the topics that actually separate mid-level from senior-level SQL interviews — execution plans, dimensional modeling, and distributed SQL reasoning — not just harder LeetCode problems.
