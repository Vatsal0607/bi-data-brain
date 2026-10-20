# Rules: OSR PAX mapping (`mappings/OSR_PAX_MAPPING.md`)

Reference file supplied by the user, not a Vertica table. Counts below are exact counts from the file received 2026-10-20; re-run `scripts/check_osr_mapping.py` when a new version arrives.

### R-MAP-001 Source, scope and grain
- **Status:** DATA-VERIFIED
- **Rule:** `OSR PAX mapping.xlsx`, one sheet (`Sheet1`), 11,447 rows, 10 columns, no blanks. One row per OSR location; `LOCATION` is unique. Every row is `ORGANIZATION_NAME = 'JAFZA'`, `PRODUCT = '7 OSR'`, `SPACE_TYPE = 'STAFF_ACCOMODATION'` (spelling as in file). Zones: Jafza North 4,128 rows, Jafza South 7,319 rows. 151 distinct `BUILDING` values; every `LOCATION` starts with its `BUILDING`.
- **SQL:** n/a (file)
- **Evidence:** Full-file profile, 2026-10-20.
- **Last verified:** 2026-10-20

### R-MAP-002 Mapping joins to facilities on location code
- **Status:** ASSUMPTION
- **Rule:** Mapping `LOCATION` is assumed to equal facility `LOCATION_CODE` (exact string, including internal spaces). Match rate not yet tested. Run `profiling/osr_mapping_join_check.sql`, export the result, then `python3 scripts/check_osr_mapping.py <mapping.xlsx> <export.csv>`.
- **SQL:** `f.LOCATION_CODE = m.LOCATION` -- CONFIRM R-MAP-002
- **Evidence:** Column names and values only; no facility extract compared yet.
- **Last verified:** 2026-10-20

### R-MAP-003 Max Pax is the maximum persons a location holds
- **Status:** ASSUMPTION
- **Rule:** `Max Pax` is read as maximum occupancy (persons) of that location, and OSR capacity is `SUM(Max Pax)`. File total 72,979; Jafza North 28,885, Jafza South 44,094. Not yet confirmed whether this is design capacity, permitted capacity or sellable beds.
- **SQL:** `SUM(max_pax)`
- **Evidence:** Column name; integer values 2 to 12. Interpretation by Claude.
- **Last verified:** 2026-10-20

### R-MAP-004 Max Pax follows room type, with an uplift in building S2C2EB04
- **Status:** DATA-VERIFIED
- **Rule:** In the file, `Max Pax` is fully determined by `FUNCTION_TYPE`, except executive units in building `S2C2EB04`, which hold more. The expression below reproduces 11,446 of 11,447 rows; the one exception is R-MAP-005. Usable in Vertica only if the facility table carries the same `FUNCTION_TYPE` values (untested, R-MAP-002).
- **SQL:** `CASE FUNCTION_TYPE WHEN 'Labour Big' THEN 12 WHEN 'AA_Labour' THEN 8 WHEN 'Labour Small' THEN 8 WHEN 'Junior' THEN 6 WHEN 'BB_Junior' THEN 6 WHEN 'CC_Senior' THEN 6 WHEN 'C_Senior' THEN 6 WHEN 'Senior' THEN 3 WHEN 'Executive - 2 BR' THEN CASE WHEN BUILDING = 'S2C2EB04' THEN 7 ELSE 4 END WHEN 'Executive - 1 BR (BIG)' THEN CASE WHEN BUILDING = 'S2C2EB04' THEN 5 ELSE 2 END WHEN 'Executive - 1 BR (SMALL)' THEN CASE WHEN BUILDING = 'S2C2EB04' THEN 5 ELSE 2 END WHEN 'Executive - Studio' THEN CASE WHEN BUILDING = 'S2C2EB04' THEN 3 ELSE 2 END END`
- **Evidence:** Crosstab of FUNCTION_TYPE x Max Pax x BUILDING, 2026-10-20; reproduced by `scripts/check_osr_mapping.py --selftest`.
- **Last verified:** 2026-10-20

### R-MAP-005 One BB_Junior row holds 3, not 6
- **Status:** ASSUMPTION
- **Rule:** `C003J101201 A` is `BB_Junior` with `Max Pax` 3; all other 1,211 BB_Junior rows are 6, including its pair `C003J101201 B`. Use the file value as given until told whether it is a deliberate exception or an entry error.
- **SQL:** use file value
- **Evidence:** Outlier check, 2026-10-20.
- **Last verified:** 2026-10-20

### R-MAP-006 Split rooms: A and B rows
- **Status:** ASSUMPTION
- **Rule:** 462 BB_Junior rooms (East OSR 208, New West OSR 254) appear as two rows with suffix ` A` and ` B` (924 rows); the unsuffixed room code is never listed. Both halves carry the same `ASSIGNABLE AREA` and, bar R-MAP-005, 6 pax each. Working treatment: each half is its own location, so area and pax are summed per row. If the area is the whole room repeated on both halves, area totals for these rooms are doubled (16,502.64 across the 924 rows).
- **SQL:** n/a
- **Evidence:** Suffix pattern check, 2026-10-20.
- **Last verified:** 2026-10-20

### R-MAP-007 Cluster, zone and building prefix line up one to one
- **Status:** DATA-VERIFIED
- **Rule:** Each building sits in one cluster and one zone. East OSR = `C003*`, Jafza North, 1,558 rows. New West OSR = `C004*`, `C005*`, `C006*`, Jafza North, 2,570 rows. South (G+6) OSR = `S2C2*`, Jafza South, 3,875 rows. South (G+10) OSR = `SA01` to `SA13` (no `SA03`), Jafza South, 3,444 rows. The G+6 value is stored with a double space: `South  (G+6) OSR`. Compare clusters after collapsing spaces.
- **SQL:** `REPLACE(TRIM(CLUSTER), '  ', ' ') AS cluster`
- **Evidence:** Crosstabs, 2026-10-20.
- **Last verified:** 2026-10-20

### R-MAP-008 Two spellings of the C004S building codes
- **Status:** ASSUMPTION
- **Rule:** 37 rows use building codes with a space (`C004S B1` to `C004S B9`); all are `C_Senior`. The same blocks also appear without the space (`C004SB1` to `C004SB9`, 395 rows, all `CC_Senior`). No location collides once spaces are removed. Working treatment: keep codes exactly as given and do not merge the two spellings, since they may mark different room types.
- **SQL:** match `BUILDING` / `LOCATION` exactly; no `REPLACE`
- **Evidence:** Building code check, 2026-10-20.
- **Last verified:** 2026-10-20

### R-MAP-009 Room types are kept as given, no cross-cluster grouping
- **Status:** ASSUMPTION
- **Rule:** 12 `FUNCTION_TYPE` values. East and New West use prefixed names (AA_Labour, BB_Junior, CC_Senior, C_Senior); South uses plain names (Labour Small, Labour Big, Junior, Senior, four Executive types). Whether AA_Labour and Labour Small (both 8 pax) or BB_Junior and Junior (both 6 pax) count as the same category is not known, so no grouping is applied.
- **SQL:** `FUNCTION_TYPE` as is
- **Evidence:** FUNCTION_TYPE x CLUSTER crosstab, 2026-10-20.
- **Last verified:** 2026-10-20

### R-MAP-010 Assignable area is in square metres
- **Status:** ASSUMPTION
- **Rule:** `ASSIGNABLE AREA` assumed to be sqm per location (range 15.20 to 49.57; file total 322,631.45). Unit not stated in the file.
- **SQL:** `SUM(assignable_area)`
- **Evidence:** Value range only. Interpretation by Claude.
- **Last verified:** 2026-10-20

### R-MAP-011 Mapping CLUSTER corresponds to facility FACILITY_CLUSTER
- **Status:** ASSUMPTION
- **Rule:** Mapping `CLUSTER` is assumed to match facility column 43 `FACILITY_CLUSTER` (R-FAC-009) for OSR rows. Not yet compared.
- **SQL:** n/a
- **Evidence:** Column name similarity only.
- **Last verified:** 2026-10-20
