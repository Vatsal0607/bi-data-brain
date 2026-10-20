# Operating protocol for Claude

This repo is the BI Data Brain for P&Z data requests (Vertica, schema `DPW_DL`). Follow this protocol on every request.

## 1. Turning a request into a query

1. Identify the tables the request touches. Read `tables/<TABLE>.md`, `joins.md`, `glossary.md` and the relevant `rules/*.md` before writing SQL. If the request needs an attribute held in a reference file (for example OSR pax or area), read its page in `mappings/` too.
2. Look for a similar past request in `requests/` and reuse its query pattern.
3. Apply rules by ID. In the SQL, mark each rule that is not `USER-CONFIRMED` or `DATA-VERIFIED` with a `-- CONFIRM R-XXX-NNN` comment.
4. In the reply, list every `ASSUMPTION` the query depends on in one short block, with its rule ID.
5. If a column, value or table has not been profiled, say so and ask or provide a profiling query. Never invent column names, functions or values.
6. Test logic with `python3 tests/sqlite_harness.py` where possible. SQLite proves logic, not Vertica syntax. Say which of the two was tested.
7. Vertica pitfalls: see `rules/sql_vertica.md` (for example, LISTAGG is not available in this environment).

### Defaults versus request-specific filters

Filters, status ticks, activity lists and keyword lists given for one request apply to that request only (R-REQ-008). Start every query from the default rules (for example R-LIC-014, R-REQ-006) and narrow only as the request says. Output cells show everything the table holds (R-REQ-007); request lists only decide which accounts or licences qualify.

## 2. Keeping the brain current (mandatory)

Whenever the user answers a question, corrects a result, pastes profiling output, or changes a requirement:

1. Update or add the rule in `rules/`: set `Status`, `Evidence` (what was seen or said, with date) and `Last verified`.
2. Never delete a wrong rule. Mark it `REJECTED` or `SUPERSEDED` and say why, so it is not proposed again.
3. Update the table page in `tables/` if a column, value profile or gotcha changed.
4. Resolve or add the item in `OPEN_QUESTIONS.md`.
5. Add a dated line to `CHANGELOG.md`.
6. Log the request in `requests/` (ask, interpretation, rule IDs, query files) and save delivered SQL in `queries/`.
7. Run `python3 scripts/lint_brain.py` and `python3 tests/sqlite_harness.py`, then commit.

Only the user can promote a rule to `USER-CONFIRMED`. Claude's own conclusions stay `ASSUMPTION` or `DATA-VERIFIED`.

## 3. Style

- Executive, brief, no filler. No enumerated lists in professional prose.
- State uncertainty plainly. Flag any statistic that has not been re-verified.
- Use "Arabian Gulf", never "Persian Gulf".
- Deliver requested queries as files, with a one-line description of what changed.
