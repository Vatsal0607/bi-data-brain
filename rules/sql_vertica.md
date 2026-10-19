# Rules: SQL and tooling

### R-SQL-001 No LISTAGG; use the slot-pivot pattern
- **Status:** DATA-VERIFIED
- **Rule:** `LISTAGG` fails in this Vertica ("Function LISTAGG(varchar, unknown) does not exist"). Build comma-separated lists with `ROW_NUMBER()`, then `COALESCE(MAX(CASE WHEN rn = i THEN ', ' || val END), '')` for each slot, concatenated, then `SUBSTR(x, 3)`. State the slot cap and append `, ...` when exceeded. `scripts/gen_slot_pivot.py` prints the expression.
- **SQL:** see `scripts/gen_slot_pivot.py`
- **Evidence:** Error screenshot from DBeaver, 2026-10-16.
- **Last verified:** 2026-10-19

### R-SQL-002 Execution and testing environment
- **Status:** USER-CONFIRMED
- **Rule:** The user runs queries in DBeaver against Vertica and pastes CSV or screenshots back. Claude cannot run Vertica. Logic is tested in SQLite on synthetic data (`tests/sqlite_harness.py`); SQLite does not validate Vertica-specific syntax.
- **SQL:** n/a
- **Evidence:** Session behaviour, 2026-10-16.
- **Last verified:** 2026-10-19

### R-SQL-003 Flag assumptions inside the SQL
- **Status:** USER-CONFIRMED
- **Rule:** Every filter that rests on an unconfirmed rule carries a `-- CONFIRM` comment so it is visible to whoever runs the query.
- **SQL:** n/a
- **Evidence:** Standing instruction to flag uncertainty, user preferences.
- **Last verified:** 2026-10-19
