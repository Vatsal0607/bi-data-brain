# Request: JAFZA companies in chemicals, fuel, gas, oil, petrochemical, waste/scrap, tank cleaning, electricity

**Date:** 2026-10-16 to 2026-10-19
**Requester:** BI & Market Research, P&Z
**Ask:** List of JAFZA companies with locations and numbers of premises / warehouses for 20 activities (original list had 23 lines).

## Interpretation

1. Find licences whose activity matches the ask exactly or closely, flagged separately (R-LIC-010, R-LIC-011).
2. Scope to in-scope licence and registration statuses (R-LIC-007, R-LIC-008), current rows (R-LIC-002), JAFZA zone (R-LIC-009).
3. For the accounts found, summarise leased JAFZA facilities by product (R-FAC-002 to R-FAC-004, R-REQ-001).
4. Then list each facility with its location ID (R-FAC-001).

## Activity list (20 unique)

Chemicals Blending; Composed Industrial Chemical Manufacturing; Basic Industrial Chemicals Trading; Industrial Solvents Trading; Acids & Alkaline Trading; Petrochemicals Trading; Fuel Trading; Refined Oil Products Trading; Production & Distribution of Gas; Industrial & Liquefied Natural Gas Trading; Gas Liquefaction & Bottling Manufacturing; Petroleum Gas Bottling; Tanks Cleaning Services; Gas Station; Fuel Distribution; Oil & Natural Gas Pipelines Contracting; Fuel Manufacturing; Petrochemical Manufacturing; Waste & Scrap handling & processing; Electricity Production.

## Outputs

| File | Grain | Notes |
|---|---|---|
| `queries/jafza_chem_fuel_gas/01_licences_by_activity.sql` | licence | Match type, exact / close / all activities, statuses |
| `queries/jafza_chem_fuel_gas/02_facility_summary_by_account.sql` | account | Licence type, match type, matched activities, facility count by product |
| `queries/jafza_chem_fuel_gas/03_facility_list_by_location.sql` | facility | Account, licence type, match type, product, space type, location ID |

## Status

Queries delivered; results not yet reviewed by the user. Open items are in `OPEN_QUESTIONS.md` (R-LIC-002, R-LIC-009, R-LIC-011, R-FAC-002, R-FAC-003, R-REQ-004).

## Lessons carried into the rules

- LISTAGG unavailable (R-SQL-001).
- IS_PREFERRED rejected as current-row rule (R-LIC-004).
- Account-level join between licences and facilities (R-FAC-005).
