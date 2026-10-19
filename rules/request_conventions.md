# Rules: request and output conventions

Defaults live here and in `rules/licence.md` / `rules/facility.md`. Anything marked request-specific does not carry over.

### R-REQ-001 Exclude accounts with no JAFZA facility from facility outputs
- **Status:** USER-CONFIRMED
- **Rule:** Facility summaries and lists show only accounts that lease at least one facility. Use an inner join to facilities.
- **SQL:** `JOIN fac f ON f.ACCOUNT_NO = a.ACCOUNT_NUMBER`
- **Evidence:** User statement, 2026-10-16.
- **Last verified:** 2026-10-19

### R-REQ-002 Output shapes
- **Status:** USER-CONFIRMED
- **Rule:** Licence outputs are one row per licence. Facility summaries are one row per account with products as columns. Facility lists are one row per facility. Multi-value cells are comma-separated.
- **SQL:** n/a
- **Evidence:** User statements, 2026-10-16 to 2026-10-19.
- **Last verified:** 2026-10-19

### R-REQ-003 Sort exact matches first
- **Status:** USER-CONFIRMED
- **Rule:** Order EXACT only, then EXACT + CLOSE, then CLOSE only. Within a group: facilities descending (summary) or account name, product, location (list).
- **SQL:** `ORDER BY CASE WHEN has_exact = 1 AND has_close = 0 THEN 1 WHEN has_exact = 1 THEN 2 ELSE 3 END`
- **Evidence:** User statement, 2026-10-19.
- **Last verified:** 2026-10-19

### R-REQ-004 Activities column shows matched activities only
- **Status:** SUPERSEDED
- **Rule:** Replaced by R-REQ-007. The activities column must show all activities, not only matched ones.
- **SQL:** n/a
- **Evidence:** User answer, 2026-10-19.
- **Last verified:** 2026-10-19

### R-REQ-005 Licence type per account is a combined list
- **Status:** ASSUMPTION
- **Rule:** An account can hold several licence types. LICENSE_TYPE in account-level and facility-level outputs is the distinct set across all of the account's in-scope licences (not only the matching ones), comma-separated, capped at 12. The user's answer "keep the licence master as is" was read as: show what the table holds, do not narrow it. Known values: Trading, General Trading, Services, Logistic, Industrial, Commercial, National Industrial, Professional, Holding, E-Commerce.
- **SQL:** see `type_str` CTE in `02_facility_summary_by_account.sql`
- **Evidence:** User answer, 2026-10-19 (interpretation by Claude).
- **Last verified:** 2026-10-19

### R-REQ-006 An organisation includes all its zones
- **Status:** USER-CONFIRMED
- **Rule:** When a request names an organisation (for example JAFZA), include all its zones unless the request says otherwise.
- **SQL:** filter on `ORG_NAME` / `ORGANIZATION_NAME`, not zone
- **Evidence:** User statement, 2026-10-19.
- **Last verified:** 2026-10-19

### R-REQ-007 Show all activities; request activity lists never ringfence
- **Status:** USER-CONFIRMED
- **Rule:** Activity lists in a request (and the exact / close flags built from them) only select which accounts or licences qualify. Output cells show all activities of the account's in-scope licences. Matches are tagged `[exact]` or `[close]`; other activities are untagged. Cap 100 with `, ...` beyond.
- **SQL:** see `acct_str` CTE in `02_facility_summary_by_account.sql`
- **Evidence:** User statement, 2026-10-19.
- **Last verified:** 2026-10-19

### R-REQ-008 Request-specific filters never become defaults
- **Status:** USER-CONFIRMED
- **Rule:** Status ticks, activity lists, keyword lists and similar filters given for one request belong to that request. Defaults are only what the rules mark as defaults (for example R-LIC-014). When a request is ambiguous about scope, use the broader default and say so.
- **SQL:** n/a
- **Evidence:** User statements, 2026-10-19.
- **Last verified:** 2026-10-19
