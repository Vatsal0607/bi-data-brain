# Rules: licence master (`DPW_DL.T_DA_CX_LICENSE_MASTER`)

### R-LIC-001 Grain is licence x activity
- **Status:** DATA-VERIFIED
- **Rule:** One licence has several rows, one per activity. Never count rows as licences. Aggregate to licence or account before joining elsewhere.
- **SQL:** `COUNT(DISTINCT LICENSE_NUMBER)`
- **Evidence:** Rows-per-licence histogram profiled in session (up to about 39 rows for one licence; verify the maximum).
- **Last verified:** 2026-10-19

### R-LIC-002 Current-row filter is not a default
- **Status:** REJECTED
- **Rule:** Do not filter on `LIC_STATUS_OLD_FLAG = 'N'` by default. The user wants all Active and Alive licences considered in every request (R-LIC-014). What the flag actually means is still to be learned from the profiling pack.
- **SQL:** n/a
- **Evidence:** User answer, 2026-10-19: no; that was for a specific request. Earlier assumption was Claude's own.
- **Last verified:** 2026-10-19

### R-LIC-003 Always distinct-count licences
- **Status:** DATA-VERIFIED
- **Rule:** Two activity-code generations share the same description text, so a licence can appear twice with the same description. Use `COUNT(DISTINCT LICENSE_NUMBER)` and `SELECT DISTINCT` on descriptions.
- **SQL:** `COUNT(DISTINCT LICENSE_NUMBER)`
- **Evidence:** Duplicate-description counts profiled in session.
- **Last verified:** 2026-10-19

### R-LIC-004 IS_PREFERRED = 1 is not the current-row rule
- **Status:** REJECTED
- **Rule:** Do not use `IS_PREFERRED = 1` to pick current rows.
- **SQL:** n/a
- **Evidence:** It dropped roughly 10% of licences overall and roughly 17.8% of Active JAFZA licences (approximate; re-verify before quoting). Some licences have no preferred row at all.
- **Last verified:** 2026-10-19

### R-LIC-005 Status and zone are row-level
- **Status:** DATA-VERIFIED
- **Rule:** `LICENSE_STATUS`, `REG_STATUS` and `ZONE_NAME` can differ across the rows of one licence. Filter at row level first, then aggregate. When one header per licence is needed, take the latest row (`BI_CREATED DESC, SUR_GKEY DESC`).
- **SQL:** `ROW_NUMBER() OVER (PARTITION BY LICENSE_NUMBER ORDER BY BI_CREATED DESC, SUR_GKEY DESC)`
- **Evidence:** Within-licence variation screenshot reviewed in session.
- **Last verified:** 2026-10-19

### R-LIC-006 ALL_LIC_ACTIVITIES is not a list
- **Status:** DATA-VERIFIED
- **Rule:** `ALL_LIC_ACTIVITIES` and `ALL_ACTIVITIES_GROUP` hold the description and code of that row only. To list all activities of a licence, aggregate `LICENSE_ACTIVITY_DESCRIPTION` across rows (see R-SQL-001).
- **SQL:** n/a
- **Evidence:** Sample of `ALL_LIC_ACTIVITIES` reviewed in session.
- **Last verified:** 2026-10-19

### R-LIC-007 Request-specific licence status list (JAFZA chem / fuel / gas request only)
- **Status:** USER-CONFIRMED
- **Rule:** For the 2026-10-16 request only, the Excel filter ticked: Active, Alive, Awaiting Amendment, Awaiting Conversion, Awaiting Creation, Awaiting Freeze, Awaiting Liquidation-TBA, Awaiting Renewal, Awaiting Termination, Expired. This is not the default; the default is R-LIC-014. Reuse only if a request names these statuses.
- **SQL:** `LICENSE_STATUS IN ('Active','Alive','Awaiting Amendment','Awaiting Conversion','Awaiting Creation','Awaiting Freeze','Awaiting Liquidation-TBA','Awaiting Renewal','Awaiting Termination','Expired')`
- **Evidence:** User shared the Excel filter screenshot, 2026-10-16; scope clarified 2026-10-19.
- **Last verified:** 2026-10-19

### R-LIC-008 Request-specific registration status list (JAFZA chem / fuel / gas request only)
- **Status:** USER-CONFIRMED
- **Rule:** For the 2026-10-16 request only, the Excel filter ticked: Active, Awaiting Amendment, Awaiting Conversion, Awaiting Freeze, Awaiting Renewal, Awaiting Termination, De Registered, Frozen. Not a default (see R-LIC-015).
- **SQL:** `REG_STATUS IN ('Active','Awaiting Amendment','Awaiting Conversion','Awaiting Freeze','Awaiting Renewal','Awaiting Termination','De Registered','Frozen')`
- **Evidence:** User shared the Excel filter screenshot, 2026-10-16; scope clarified 2026-10-19.
- **Last verified:** 2026-10-19

### R-LIC-009 JAFZA at licence level by ZONE_NAME
- **Status:** SUPERSEDED
- **Rule:** Replaced by R-LIC-016. `ZONE_NAME = 'Jebel Ali Free Zone'` is too narrow: JAFZA has several zones and all must be considered.
- **SQL:** n/a
- **Evidence:** User answer, 2026-10-19.
- **Last verified:** 2026-10-19

### R-LIC-010 Exact activity match method
- **Status:** USER-CONFIRMED
- **Rule:** Exact matches compare `LOWER(TRIM(LICENSE_ACTIVITY_DESCRIPTION))` with a requested name list; close matches are flagged separately. The list (20 unique names for the 2026-10-16 request; 17 found with exact text) belongs to that request only. Each future request supplies its own activity list.
- **SQL:** `LOWER(TRIM(LICENSE_ACTIVITY_DESCRIPTION)) = e.nm`
- **Evidence:** User instruction 2026-10-16: match the ask, plus anything closely matching, flagged separately. Scope clarified 2026-10-19.
- **Last verified:** 2026-10-19

### R-LIC-011 Close-match keywords (request-specific)
- **Status:** ASSUMPTION
- **Rule:** For the 2026-10-16 request, an activity was a close match when, padded with spaces and lower-cased, it contains one of: chemical, solvent, ` acid`, alkal, blending, petro, fuel, refin, ` gas `, ` oil `, ` lng `, ` lpg `, liquef, bottling, tank, pipeline, waste, scrap, electricity, power gener. Proposed by Claude. The answer "Yes" to "anything to add or remove?" is ambiguous and awaits clarification. Keywords are per request, not global.
- **SQL:** `LOWER(' ' || act || ' ') LIKE '%' || k || '%'`
- **Evidence:** See `queries/jafza_chem_fuel_gas/01_licences_by_activity.sql`.
- **Last verified:** 2026-10-19

### R-LIC-012 Load date does not separate old from new rows
- **Status:** REJECTED
- **Rule:** Do not infer old versus new licence rows from the load date (for example 2024 = old, 2025 = new).
- **SQL:** n/a
- **Evidence:** Load date profile in session did not separate the two.
- **Last verified:** 2026-10-19

### R-LIC-013 Blank activity codes do not explain duplicates
- **Status:** REJECTED
- **Rule:** Blank activity codes were suspected as the cause of odd duplicate counts. Preferred rows have no blank codes, so this is not the explanation.
- **SQL:** n/a
- **Evidence:** Completeness check (query F) in session.
- **Last verified:** 2026-10-19

### R-LIC-014 Default licence scope: Active and Alive
- **Status:** USER-CONFIRMED
- **Rule:** Unless a request says otherwise, consider all licences with `LICENSE_STATUS` Active or Alive, with no current-row flag filter. Other statuses enter only when the request names them.
- **SQL:** `LICENSE_STATUS IN ('Active','Alive')`
- **Evidence:** User statement, 2026-10-19.
- **Last verified:** 2026-10-19

### R-LIC-015 No registration-status filter by default
- **Status:** ASSUMPTION
- **Rule:** Registration status is not filtered by default. The ticked list in R-LIC-008 was request-specific. Confirm whether a default registration-status rule is wanted.
- **SQL:** n/a
- **Evidence:** Inferred from the 2026-10-19 answer that the Excel ticks were request-specific.
- **Last verified:** 2026-10-19

### R-LIC-016 JAFZA at licence level is the organisation, all zones
- **Status:** USER-CONFIRMED
- **Rule:** A JAFZA licence is identified by `ORG_NAME`, not by `ZONE_NAME`. All zones under the JAFZA organisation are included unless the request narrows them (R-REQ-006).
- **SQL:** `ORG_NAME = 'JAFZA'` (value to be verified, R-LIC-017)
- **Evidence:** User statement, 2026-10-19: use Org name; JAFZA has multiple zones; all considered.
- **Last verified:** 2026-10-19

### R-LIC-017 Exact ORG_NAME value for JAFZA in the licence master
- **Status:** ASSUMPTION
- **Rule:** The query assumes the value is `JAFZA`, matching the facility table. It has not been seen in licence-master output. If it differs, the query returns no rows; change it in the `cur` CTE only. Run profiling query 1 in `profiling/license_master_profile.sql`.
- **SQL:** `ORG_NAME = 'JAFZA'`
- **Evidence:** Not yet profiled.
- **Last verified:** 2026-10-19
