# Rules: licence master (`DPW_DL.T_DA_CX_LICENSE_MASTER`)

### R-LIC-001 Grain is licence x activity
- **Status:** DATA-VERIFIED
- **Rule:** One licence has several rows, one per activity. Never count rows as licences. Aggregate to licence or account before joining elsewhere.
- **SQL:** `COUNT(DISTINCT LICENSE_NUMBER)`
- **Evidence:** Rows-per-licence histogram profiled in session (up to about 39 rows for one licence; verify the maximum).
- **Last verified:** 2026-10-19

### R-LIC-002 Current-row filter
- **Status:** ASSUMPTION
- **Rule:** Keep only current rows with `LIC_STATUS_OLD_FLAG = 'N'`.
- **SQL:** `AND LIC_STATUS_OLD_FLAG = 'N'`
- **Evidence:** Chosen after `IS_PREFERRED = 1` was rejected (R-LIC-004). Not yet confirmed by the data owner.
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

### R-LIC-007 In-scope licence statuses
- **Status:** USER-CONFIRMED
- **Rule:** Licence status in: Active, Alive, Awaiting Amendment, Awaiting Conversion, Awaiting Creation, Awaiting Freeze, Awaiting Liquidation-TBA, Awaiting Renewal, Awaiting Termination, Expired. Source: ticked values in the user's Excel filter.
- **SQL:** `LICENSE_STATUS IN ('Active','Alive','Awaiting Amendment','Awaiting Conversion','Awaiting Creation','Awaiting Freeze','Awaiting Liquidation-TBA','Awaiting Renewal','Awaiting Termination','Expired')`
- **Evidence:** User shared the Excel filter screenshot, 2026-10-16.
- **Last verified:** 2026-10-19

### R-LIC-008 In-scope registration statuses
- **Status:** USER-CONFIRMED
- **Rule:** Registration status in: Active, Awaiting Amendment, Awaiting Conversion, Awaiting Freeze, Awaiting Renewal, Awaiting Termination, De Registered, Frozen. Source: ticked values in the user's Excel filter.
- **SQL:** `REG_STATUS IN ('Active','Awaiting Amendment','Awaiting Conversion','Awaiting Freeze','Awaiting Renewal','Awaiting Termination','De Registered','Frozen')`
- **Evidence:** User shared the Excel filter screenshot, 2026-10-16.
- **Last verified:** 2026-10-19

### R-LIC-009 JAFZA at licence level
- **Status:** ASSUMPTION
- **Rule:** A JAFZA licence row has `ZONE_NAME = 'Jebel Ali Free Zone'`. The user's filter was on the "Org. Zone" field; the exact column mapping and its alignment with `ORG_NAME` are unconfirmed.
- **SQL:** `ZONE_NAME = 'Jebel Ali Free Zone'`
- **Evidence:** Alignment profile (ORG_NAME x ZONE_NAME) requested, result not yet recorded.
- **Last verified:** 2026-10-19

### R-LIC-010 Exact activity match method
- **Status:** USER-CONFIRMED
- **Rule:** Exact matches compare `LOWER(TRIM(LICENSE_ACTIVITY_DESCRIPTION))` with the requested names. Exact and close matches are flagged separately. The requested list has 20 unique names (23 lines in the original ask); 17 of 20 were found with exact text in the data.
- **SQL:** `LOWER(TRIM(LICENSE_ACTIVITY_DESCRIPTION)) = e.nm`
- **Evidence:** User instruction 2026-10-16: match the ask, plus anything closely matching, flagged separately.
- **Last verified:** 2026-10-19

### R-LIC-011 Close-match keywords
- **Status:** ASSUMPTION
- **Rule:** An activity is a close match when, padded with spaces and lower-cased, it contains one of: chemical, solvent, ` acid`, alkal, blending, petro, fuel, refin, ` gas `, ` oil `, ` lng `, ` lpg `, liquef, bottling, tank, pipeline, waste, scrap, electricity, power gener. Keyword list was proposed by Claude, not confirmed.
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
