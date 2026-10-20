# BI Data Brain

Living knowledge base for P&Z Business Intelligence data requests on Vertica (schema `DPW_DL`).

**Goal:** ask for data in plain words and get a query that applies the right tables, filters and business logic first time, with every assumption flagged.

## How it works

| Folder / file | What it holds |
|---|---|
| `CLAUDE.md` | Operating protocol: how Claude turns a request into a query, and how it updates this repo after every correction |
| `rules/` | One entry per business or technical rule, each with an ID, a status, evidence and a last-verified date |
| `tables/` | One page per table: grain, keys, columns, value profiles, gotchas |
| `mappings/` | One page per reference file supplied by the user (for example the OSR PAX mapping): grain, join key, value profile |
| `glossary.md` | Business terms mapped to the rules that define them |
| `joins.md` | Confirmed join paths between tables |
| `queries/` | Delivered SQL, grouped by request |
| `requests/` | Log of each request: ask, interpretation, rules applied, outputs |
| `profiling/` | Reusable profiling playbook for learning a new table |
| `tests/` | SQLite harness that checks query logic on synthetic data (logic only, not Vertica syntax) |
| `OPEN_QUESTIONS.md` | Assumptions waiting for a human to confirm |
| `CHANGELOG.md` | Every change to a rule, with the reason |

## Rule statuses

- `USER-CONFIRMED`: stated or approved by the data owner
- `DATA-VERIFIED`: observed in query output, not yet confirmed as intended business logic
- `ASSUMPTION`: working default, must be flagged in any query that uses it and listed in `OPEN_QUESTIONS.md`
- `REJECTED`: tested and found wrong; kept so it is not re-proposed
- `SUPERSEDED`: replaced by a newer rule (names the replacement)

## Keeping it healthy

```
python3 scripts/lint_brain.py          # structure, IDs, statuses, open-question coverage
python3 tests/sqlite_harness.py        # regression test of delivered queries on synthetic data
python3 scripts/build_snapshot.py      # one-file digest for pasting into a Claude Project
```

CI runs the first two on every push.

## Data handling

This repo is for internal use. Keep it private. It holds table structure, filters and aggregate profiles only. Do not commit customer-level extracts or query results.
