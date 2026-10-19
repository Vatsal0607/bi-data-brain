# Rules: request and output conventions

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

### R-REQ-004 MATCHED_ACTIVITIES content
- **Status:** ASSUMPTION
- **Rule:** The activities column lists matched activities only (exact first, then close tagged `[close]`). Showing all licence activities is a possible alternative.
- **SQL:** see `02_facility_summary_by_account.sql`
- **Evidence:** User asked for activities after the match type; scope not specified.
- **Last verified:** 2026-10-19

### R-REQ-005 Licence type per account is a combined list
- **Status:** ASSUMPTION
- **Rule:** An account can hold several licence types. LICENSE_TYPE in account-level and facility-level outputs is the distinct set across the account's matched licences, comma-separated, capped at 12. Known values: Trading, General Trading, Services, Logistic, Industrial, Commercial, National Industrial, Professional, Holding, E-Commerce.
- **SQL:** see `type_str` CTE in `02_facility_summary_by_account.sql`
- **Evidence:** User asked "Add License type also"; handling of multiple types was Claude's choice.
- **Last verified:** 2026-10-19
