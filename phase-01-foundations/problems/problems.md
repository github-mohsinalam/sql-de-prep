# Phase 1 — Practice Problems

LeetCode SQL 50 (Select + intro). Listed in the order solved (easy → tricky),
not numeric order. Solutions in [`solutions/`](../solutions), one file per
problem.

| # | Problem | Difficulty | Pattern | Solution |
|---|---|---|---|---|
| 595 | Big Countries | Easy | `WHERE` / `OR` | [sql](../solutions/595-big-countries.sql) |
| 620 | Not Boring Movies | Easy | `WHERE` + modulo, NULL-safe compare | [sql](../solutions/620-not-boring-movies.sql) |
| 1873 | Calculate Special Bonus | Easy | `CASE`, sargable `LIKE` | [sql](../solutions/1873-calculate-special-bonus.sql) |
| 182 | Duplicate Emails | Easy | `GROUP BY … HAVING` | [sql](../solutions/182-duplicate-emails.sql) |
| 183 | Customers Who Never Order | Easy | anti-join (`NOT EXISTS`) | [sql](../solutions/183-customers-who-never-order.sql) |
| 181 | Employees Earning More Than Their Managers | Easy | self-join | [sql](../solutions/181-employees-earning-more-than-managers.sql) |
| 176 | Second Highest Salary | Medium | scalar subquery → NULL on empty | [sql](../solutions/176-second-highest-salary.sql) |

---

## 595. Big Countries — Easy

**Table: `World`** — `name` (PK), `continent`, `area`, `population`, `gdp`.

A country is **big** if `area >= 3000000` **or** `population >= 25000000`. Report
`name`, `population`, `area`. Any order.

---

## 620. Not Boring Movies — Easy

**Table: `Cinema`** — `id` (PK), `movie`, `description`, `rating`.

Report movies with an **odd `id`** and `description` **not** `"boring"`. Order by
`rating` descending. Return all columns.

---

## 1873. Calculate Special Bonus — Easy

**Table: `Employees`** — `employee_id` (PK), `name`, `salary`.

`bonus` = 100% of `salary` if `employee_id` is **odd** **and** `name` does **not**
start with `'M'`; otherwise `0`. Return `employee_id`, `bonus`. Order by
`employee_id`.

---

## 182. Duplicate Emails — Easy

**Table: `Person`** — `id` (PK), `email` (guaranteed non-NULL).

Report all **duplicate** emails. Any order. Output column: `Email`.

---

## 183. Customers Who Never Order — Easy

**Table: `Customers`** — `id` (PK), `name`.
**Table: `Orders`** — `id` (PK), `customerId` (FK → `Customers.id`).

Find customers who **never order**. Any order. Output column: `Customers`.

---

## 181. Employees Earning More Than Their Managers — Easy

**Table: `Employee`** — `id` (PK), `name`, `salary`, `managerId` (FK →
`Employee.id`, NULL if no manager).

Find employees who earn **more than their managers**. Any order. Output column:
`Employee`.

---

## 176. Second Highest Salary — Medium

**Table: `Employee`** — `id` (PK), `salary`.

Return the **second highest distinct** salary, or **`NULL`** if there is none.
Output column: `SecondHighestSalary`. `{100,200,300}` → `200`; `{100}` → `NULL`.
