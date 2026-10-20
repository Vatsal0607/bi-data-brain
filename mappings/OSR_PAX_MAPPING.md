# Mapping: OSR PAX mapping

**Source:** `OSR PAX mapping.xlsx`, sheet `Sheet1`, supplied by the user 2026-10-20 (Claude Project file). Not stored in this repo; keep the original with the user.
**Purpose:** room-level attributes for JAFZA staff accommodation (product 7 OSR): building, room type, cluster, maximum persons and assignable area.
**Grain:** one row per OSR location; `LOCATION` unique, 11,447 rows (R-MAP-001).
**Join key:** `LOCATION` to facility `LOCATION_CODE`, untested (R-MAP-002).

## Columns

| Column | Meaning / notes | Rules |
|---|---|---|
| LOCATION | Room or room-half code; starts with BUILDING; 924 rows end in ` A` / ` B` | R-MAP-002, R-MAP-006 |
| BUILDING | 151 codes; prefix gives the cluster; `C004S B1..B9` also spelled without the space | R-MAP-007, R-MAP-008 |
| SPACE_TYPE | Always `STAFF_ACCOMODATION` | R-MAP-001 |
| FUNCTION_TYPE | Room type, 12 values (below) | R-MAP-004, R-MAP-009 |
| PRODUCT | Always `7 OSR` (same code as facility `PRODUCT_SPACE_TYPE`, R-FAC-004) | R-MAP-001 |
| CLUSTER | East OSR, New West OSR, `South  (G+6) OSR` (double space), South (G+10) OSR | R-MAP-007, R-MAP-011 |
| Max Pax | Integer 2 to 12; read as maximum persons | R-MAP-003, R-MAP-004 |
| ZONE_NAME | Jafza North, Jafza South | R-MAP-007 |
| ORGANIZATION_NAME | Always JAFZA | R-MAP-001 |
| ASSIGNABLE AREA | 15.20 to 49.57; unit assumed sqm | R-MAP-010 |

## Profile by cluster (file of 2026-10-20)

| Cluster | Zone | Buildings | Locations | Max Pax | Area |
|---|---|---|---|---|---|
| East OSR | Jafza North | 74 | 1,558 | 10,909 | 34,594.44 |
| New West OSR | Jafza North | 45 | 2,570 | 17,976 | 61,369.42 |
| South (G+6) OSR | Jafza South | 20 | 3,875 | 23,430 | 117,967.99 |
| South (G+10) OSR | Jafza South | 12 | 3,444 | 20,664 | 108,699.60 |
| Total | | 151 | 11,447 | 72,979 | 322,631.45 |

Area totals include the 924 A/B half-rooms as listed (R-MAP-006).

## Room types

| FUNCTION_TYPE | Cluster(s) | Locations | Max Pax per location | Typical area |
|---|---|---|---|---|
| AA_Labour | East 782, New West 1,278 | 2,060 | 8 | 27.74 to 31.68 |
| BB_Junior | East 416, New West 796 | 1,212 | 6 (one row 3, R-MAP-005) | 16.45 to 18.80 |
| CC_Senior | East 360, New West 458 | 818 | 6 | 15.20 to 45.57 |
| C_Senior | New West | 38 | 6 | 15.20 to 31.90 |
| Labour Small | South G+6 | 2,279 | 8 | 31.80 to 33.25 |
| Labour Big | South G+6 | 54 | 12 | 44.64 |
| Senior | South G+6 | 880 | 3 | 18.90 |
| Executive - Studio | South G+6 | 48 | 2; 3 in S2C2EB04 | 21.61 |
| Executive - 1 BR (SMALL) | South G+6 | 390 | 2; 5 in S2C2EB04 | 39.39 to 39.90 |
| Executive - 1 BR (BIG) | South G+6 | 168 | 2; 5 in S2C2EB04 | 40.82 to 41.13 |
| Executive - 2 BR | South G+6 | 56 | 4; 7 in S2C2EB04 | 49.53 to 49.57 |
| Junior | South G+10 | 3,444 | 6 | 30.80 to 39.60 |

## Gotchas

- `South  (G+6) OSR` carries a double space; a plain `= 'South (G+6) OSR'` filter returns nothing (R-MAP-007).
- Building `S2C2EB04` (166 executive units) holds more persons per unit than EB01 to EB03 (R-MAP-004).
- The 37 `C004S B*` rows with a space are all `C_Senior`; the unspaced `C004SB*` rows are `CC_Senior` (R-MAP-008).
- Facility `FUNCTION_TYPE` has about 100 values (R-FAC-008); whether these 12 OSR values appear there unchanged is untested.

## How to refresh

When a new version of the file arrives, run `python3 scripts/check_osr_mapping.py <file.xlsx> --selftest` and update this page and `rules/osr_mapping.md` with any change in counts or patterns.
