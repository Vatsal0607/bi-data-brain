# DPW_DL.T_DA_CX_LICENSE_MASTER

**Purpose:** licences and their registered activities for customer accounts.
**Grain:** one row per licence x activity (R-LIC-001). Not unique on `LICENSE_NUMBER`.
**Account key:** `ACCOUNT_NUMBER` (joins to facility `ACCOUNT_NO`, R-FAC-005).

## Columns seen so far

| Column | Meaning / notes | Rules |
|---|---|---|
| SUR_GKEY | Surrogate row key | |
| LICENSE_NUMBER | Licence ID, repeats across activity rows | R-LIC-001 |
| ACCOUNT_NUMBER, ACCOUNT_NAME | Customer account | R-FAC-005 |
| ORG_NAME, ZONE_NAME | Organisation (the JAFZA basis, R-LIC-016) and zone of the licence row; row-level, can differ within a licence. Exact ORG_NAME values not yet profiled | R-LIC-005, R-LIC-016, R-LIC-017 |
| LICENSE_STATUS, REG_STATUS | Licence and customer registration status; row-level | R-LIC-005, R-LIC-007, R-LIC-008 |
| LICENSE_TYPE | Trading, General Trading, Services, Logistic, Industrial, Commercial, National Industrial, Professional, Holding, E-Commerce | R-REQ-005 |
| LICENSE_ACTIVITY_DESCRIPTION | Activity text for the row | R-LIC-003, R-LIC-010 |
| ALL_LIC_ACTIVITIES, ALL_ACTIVITIES_GROUP | Per-row activity description and code, not lists | R-LIC-006 |
| LIC_STATUS_OLD_FLAG | Meaning not yet established; not used as a default filter | R-LIC-002 |
| IS_PREFERRED | Not a reliable current-row flag | R-LIC-004 |
| BI_CREATED | Load timestamp; does not separate old from new | R-LIC-012 |

To learn the whole table (all values of organisation, zone, status, type), run `profiling/license_master_profile.sql` and send the output; each result goes into this page. This list is partial. Add columns here as they are profiled; run the structure query in `profiling/new_table_playbook.md` to see the rest.

## Gotchas

- Two activity-code generations share the same description text; always distinct-count (R-LIC-003).
- Roughly 10% of licences have no `IS_PREFERRED = 1` row (R-LIC-004).
- Rows of one licence can carry different statuses or zones (R-LIC-005).
