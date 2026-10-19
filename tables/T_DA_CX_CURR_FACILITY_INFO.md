# DPW_DL.T_DA_CX_CURR_FACILITY_INFO

**Purpose:** current facilities (plots, warehouses, offices and so on) with status and the account that holds them.
**Grain:** one row per facility, `LOCATION_CODE` unique (R-FAC-001).
**Account key:** `ACCOUNT_NO` (R-FAC-005).

## Columns seen so far

| Column | Meaning / notes | Rules |
|---|---|---|
| SUR_GKEY | Column 1, surrogate key | R-FAC-009 |
| LOCATION_CODE | Facility ID; unique | R-FAC-001 |
| ACCOUNT_NO | Account holding the facility; blank for some (about 340 Under Amendment) | R-FAC-005, R-FAC-007 |
| ORGANIZATION_NAME | JAFZA, National Industries Park, FVM, Dubai Auto Zone, DAM, Textile City | R-FAC-002 |
| ZONE_NAME | Sub-zone: Jafza North, Jafza South, TechnoPark, Emaar, Limitless, NIP, FVM, DAM, Ducamz and others | R-FAC-002 |
| STATUS_GROUP, STATUS | Leased group contains Leased, Under Renewal, Under Legal, Under Termination | R-FAC-003 |
| PRODUCT_SPACE_TYPE | "Product": 1 Plot, 2 LIU Warehouse, 3 Showroom, 4 Office, 5 Workstation, 6 Retail, 7 OSR | R-FAC-004 |
| SPACE_TYPE | Messy, case variants | R-FAC-008 |
| FUNCTION_TYPE | About 100 values | R-FAC-008 |
| FAC_REGION | Ignore | R-FAC-006 |
| FACILITY_CLUSTER | Column 43 | R-FAC-009 |

Partial list. The table has at least 43 columns; extend as they are profiled.

## Gotchas

- Facilities without an account are invisible in per-account outputs (R-FAC-007).
- `ORGANIZATION_NAME = 'JAFZA'` spans several sub-zones with different `ZONE_NAME` (R-FAC-002).
- Do not use `SPACE_TYPE` as "product" (R-FAC-004, R-FAC-008).
