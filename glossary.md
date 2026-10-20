# Glossary

| Term | Working definition | Rules |
|---|---|---|
| In-scope licence (default) | `LICENSE_STATUS` Active or Alive; no current-row flag | R-LIC-014 |
| Exact activity match | `LOWER(TRIM(LICENSE_ACTIVITY_DESCRIPTION))` equals a name on the requested list | R-LIC-010 |
| Close activity match | Not exact, but description contains a requested keyword | R-LIC-011 |
| Request-specific licence status list | Ticked Excel values for the 2026-10-16 request only | R-LIC-007 |
| Request-specific registration status list | Ticked Excel values for the 2026-10-16 request only | R-LIC-008 |
| JAFZA licence | Licence row with `ORG_NAME = 'JAFZA'`, all zones | R-LIC-016, R-LIC-017 |
| JAFZA facility | Facility row with `ORGANIZATION_NAME = 'JAFZA'`, all zones | R-FAC-002 |
| Leased facility | Facility row with `STATUS_GROUP = 'Leased'` | R-FAC-003 |
| Product | `PRODUCT_SPACE_TYPE` of the facility | R-FAC-004 |
| Facility ID / Location ID | `LOCATION_CODE` (unique per facility) | R-FAC-001 |
| OSR | Staff accommodation, product `7 OSR`; room attributes in the OSR PAX mapping | R-FAC-004, R-MAP-001 |
| Max Pax / OSR capacity | Maximum persons per OSR location; capacity = sum of Max Pax (meaning to confirm) | R-MAP-003, R-MAP-004 |
| OSR cluster | East OSR, New West OSR, South (G+6) OSR, South (G+10) OSR | R-MAP-007, R-MAP-011 |
| OSR room type | Mapping `FUNCTION_TYPE`, 12 values, kept as given | R-MAP-009 |
| Split room (A / B) | BB_Junior room listed as two halves, ` A` and ` B` | R-MAP-006 |
| Assignable area | Mapping `ASSIGNABLE AREA`, assumed sqm | R-MAP-010 |
