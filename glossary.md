# Glossary

| Term | Working definition | Rules |
|---|---|---|
| Current licence row | Row in the licence master with `LIC_STATUS_OLD_FLAG = 'N'` | R-LIC-002 |
| Exact activity match | `LOWER(TRIM(LICENSE_ACTIVITY_DESCRIPTION))` equals a name on the requested list | R-LIC-010 |
| Close activity match | Not exact, but description contains a requested keyword | R-LIC-011 |
| In-scope licence status | Ticked values from the Excel filter (see rule) | R-LIC-007 |
| In-scope registration status | Ticked values from the Excel filter (see rule) | R-LIC-008 |
| JAFZA licence | Licence row with `ZONE_NAME = 'Jebel Ali Free Zone'` | R-LIC-009 |
| JAFZA facility | Facility row with `ORGANIZATION_NAME = 'JAFZA'` | R-FAC-002 |
| Leased facility | Facility row with `STATUS_GROUP = 'Leased'` | R-FAC-003 |
| Product | `PRODUCT_SPACE_TYPE` of the facility | R-FAC-004 |
| Facility ID / Location ID | `LOCATION_CODE` (unique per facility) | R-FAC-001 |
