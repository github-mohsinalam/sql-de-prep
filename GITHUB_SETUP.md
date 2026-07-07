# Getting this onto GitHub

From inside the `sql-senior-de-prep/` folder:

```bash
git init
git add .
git commit -m "Initial repo scaffold: roadmap, phase structure, Postgres practice env"
```

Create a new repo on GitHub (via web UI or `gh repo create`), then:

```bash
git branch -M main
git remote add origin https://github.com/<your-username>/sql-senior-de-prep.git
git push -u origin main
```

## If you plan to open-source this later

- Consider adding an actual LICENSE file (MIT is a common permissive choice for study-note repos) — not included by default here since it's your call
- Scrub anything you don't want public before making the repo public (e.g. if any notes reference internal work details from your actual DE job)
- The README already has a "why this exists" section aimed at other data engineers — update the roadmap table's status column as you go so it stays useful as a live reference
