# Local Postgres Practice Environment

Docker-based Postgres instance, pre-seeded with tables matching common LeetCode SQL 50 / StrataScratch problem shapes (employee/department, product/sales, customer/orders, weather). Use this to actually run and test queries locally instead of only in the LeetCode browser editor — closer to how you'll reason about queries in real interviews and on the job.

## Prerequisites

- Docker Desktop installed and running (with WSL2 backend, since you're on Windows — Docker Desktop settings → General → "Use the WSL 2 based engine")

## Start the environment

From the `postgres-setup/` folder:

```bash
docker compose up -d
```

This starts Postgres 16 on `localhost:5432` and auto-runs the scripts in `init/` (schema + seed data) on first boot only.

**Credentials:**
- Host: `localhost`
- Port: `5432`
- Database: `sqlprep`
- User: `sqlprep`
- Password: `sqlprep`

## Connect

**Option A — psql inside the container (no local install needed):**
```bash
docker exec -it sql-prep-postgres psql -U sqlprep -d sqlprep
```

**Option B — a GUI client:** DBeaver (free, cross-platform) or the VS Code "PostgreSQL" extension both work well — just point them at the credentials above.

**Option C — psql installed locally / in WSL:**
```bash
psql -h localhost -U sqlprep -d sqlprep
```

## Resetting the data

If you modify seed data and want a clean slate:
```bash
docker compose down -v   # -v removes the volume, wiping data
docker compose up -d     # re-runs init scripts fresh
```

## Adding tables for later phases

Later phases (especially 09 — Dimensional Modeling) will need different table shapes (fact/dimension tables, SCD examples). Add new `.sql` files to `init/` prefixed with the next number (e.g. `03_dimensional_model.sql`) — they run in alphabetical order — then reset the environment as above.

## Stopping

```bash
docker compose down
```
(Data persists in the Docker volume unless you use `-v`.)
