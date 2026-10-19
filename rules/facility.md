# Rules: facilities (`DPW_DL.T_DA_CX_CURR_FACILITY_INFO`)

### R-FAC-001 Grain is one row per facility
- **Status:** DATA-VERIFIED
- **Rule:** `LOCATION_CODE` is unique per row. It is the facility ID / location ID in outputs.
- **SQL:** `COUNT(DISTINCT LOCATION_CODE)`
- **Evidence:** Grain check in session.
- **Last verified:** 2026-10-19

### R-FAC-002 JAFZA at facility level
- **Status:** ASSUMPTION
- **Rule:** JAFZA means `ORGANIZATION_NAME = 'JAFZA'`. This includes ZONE_NAME values Jafza North, Jafza South, TechnoPark, Emaar, Limitless, Fresh Fruit & Vegetable, JAFZA and blank. Other organisations in the table: National Industries Park, FVM, Dubai Auto Zone, DAM, Textile City.
- **SQL:** `ORGANIZATION_NAME = 'JAFZA'`
- **Evidence:** Organisation x zone profile (Query_3.csv), 2026-10-16. Not yet confirmed by the user.
- **Last verified:** 2026-10-19

### R-FAC-003 Leased facility
- **Status:** ASSUMPTION
- **Rule:** Leased means `STATUS_GROUP = 'Leased'`. This group contains the statuses Leased, Under Renewal, Under Legal and Under Termination. It does not contain Under Amendment.
- **SQL:** `STATUS_GROUP = 'Leased'`
- **Evidence:** Status-group x status crosstab, 2026-10-16. Not yet confirmed by the user.
- **Last verified:** 2026-10-19

### R-FAC-004 Product is PRODUCT_SPACE_TYPE
- **Status:** USER-CONFIRMED
- **Rule:** "Product" means `PRODUCT_SPACE_TYPE`. Values: 1 Plot, 2 LIU Warehouse, 3 Showroom, 4 Office, 5 Workstation, 6 Retail, 7 OSR, plus one stray row `G+10 Complex`. Anything else is reported as OTHER_PRODUCTS.
- **SQL:** `TRIM(PRODUCT_SPACE_TYPE) AS product`
- **Evidence:** User statement, 2026-10-16.
- **Last verified:** 2026-10-19

### R-FAC-005 Facility to licence link is the account number
- **Status:** USER-CONFIRMED
- **Rule:** `ACCOUNT_NO` (facility) matches `ACCOUNT_NUMBER` (licence master).
- **SQL:** `f.ACCOUNT_NO = a.ACCOUNT_NUMBER`
- **Evidence:** User statement, 2026-10-16.
- **Last verified:** 2026-10-19

### R-FAC-006 Ignore FAC_REGION and the source column
- **Status:** USER-CONFIRMED
- **Rule:** Do not filter or group by `FAC_REGION` or the source column.
- **SQL:** n/a
- **Evidence:** User statements, 2026-10-16.
- **Last verified:** 2026-10-19

### R-FAC-007 Facilities without an account are invisible per account
- **Status:** DATA-VERIFIED
- **Rule:** Facilities with no `ACCOUNT_NO` cannot appear in per-account outputs. About 340 Under Amendment facilities have no account (approximate; re-verify).
- **SQL:** `AND ACCOUNT_NO IS NOT NULL AND TRIM(ACCOUNT_NO) <> ''`
- **Evidence:** Status crosstab, 2026-10-16.
- **Last verified:** 2026-10-19

### R-FAC-008 SPACE_TYPE is messy, PRODUCT_SPACE_TYPE is clean
- **Status:** DATA-VERIFIED
- **Rule:** `SPACE_TYPE` has case variants (for example WAREHOUSE and Warehouse). `FUNCTION_TYPE` has about 100 values. Use `UPPER(TRIM(SPACE_TYPE))` if a uniform value is needed.
- **SQL:** `TRIM(SPACE_TYPE) AS space_type`
- **Evidence:** Column profile, 2026-10-16.
- **Last verified:** 2026-10-19

### R-FAC-009 Column positions noted by the user
- **Status:** USER-CONFIRMED
- **Rule:** Column 1 is `SUR_GKEY`; column 43 is `FACILITY_CLUSTER`.
- **SQL:** n/a
- **Evidence:** User statement, 2026-10-16.
- **Last verified:** 2026-10-19
