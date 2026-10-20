# DPW_DL.T_DA_CX_CURR_FACILITY_INFO

**Purpose:** current facilities (plots, warehouses, offices and so on) with status and the account that holds them.
**Grain:** one row per facility, `LOCATION_CODE` unique (R-FAC-001).
**Account key:** `ACCOUNT_NO` (R-FAC-005).

## Columns seen so far

| Column | Meaning / notes | Rules |
|---|---|---|
| SUR_GKEY | Column 1, surrogate key | R-FAC-009 |
| LOCATION_CODE | Facility ID; unique. For OSR, assumed to equal mapping `LOCATION` | R-FAC-001, R-MAP-002 |
| ACCOUNT_NO | Account holding the facility; blank for some (about 340 Under Amendment) | R-FAC-005, R-FAC-007 |
| ORGANIZATION_NAME | JAFZA, National Industries Park, FVM, Dubai Auto Zone, DAM, Textile City | R-FAC-002 |
| ZONE_NAME | Sub-zone: Jafza North, Jafza South, TechnoPark, Emaar, Limitless, NIP, FVM, DAM, Ducamz and others | R-FAC-002 |
| STATUS_GROUP, STATUS | Leased group contains Leased, Under Renewal, Under Legal, Under Termination | R-FAC-003 |
| PRODUCT_SPACE_TYPE | "Product": 1 Plot, 2 LIU Warehouse, 3 Showroom, 4 Office, 5 Workstation, 6 Retail, 7 OSR. 7 OSR rooms have pax and area in the OSR PAX mapping | R-FAC-004, R-MAP-001 |
| SPACE_TYPE | Messy, case variants | R-FAC-008 |
| FUNCTION_TYPE | About 100 values; the OSR mapping holds 12 room types, overlap untested | R-FAC-008, R-MAP-004, R-MAP-009 |
| FAC_REGION | Ignore | R-FAC-006 |
| FACILITY_CLUSTER | Column 43; assumed to carry the OSR mapping CLUSTER values | R-FAC-009, R-MAP-011 |

Partial list. The table has at least 43 columns; extend as they are profiled.

## Gotchas

- Facilities without an account are invisible in per-account outputs (R-FAC-007).
- `ORGANIZATION_NAME = 'JAFZA'` spans several sub-zones with different `ZONE_NAME` (R-FAC-002).
- Do not use `SPACE_TYPE` as "product" (R-FAC-004, R-FAC-008).
- OSR occupancy (Max Pax) and assignable area are not in this table as far as profiled; they come from `mappings/OSR_PAX_MAPPING.md`, joined by location code (R-MAP-002).
