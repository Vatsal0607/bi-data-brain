# Open questions

Each `ASSUMPTION` rule must appear here until a human confirms or rejects it. Format: `- [ ] R-XXX-NNN: question`. Tick and move to Resolved when answered.

- [ ] R-LIC-011: Does "Yes" to "anything to add or remove?" mean the close-match keyword list is fine as is, or that changes are wanted?
- [ ] R-LIC-015: Should any registration status filter apply by default, or none?
- [ ] R-LIC-017: What exact `ORG_NAME` value(s) identify JAFZA in the licence master? Run profiling query 1.
- [ ] R-REQ-005: Show the account's licence types combined in one cell (current), or in another shape?
- [ ] R-MAP-002: Does mapping LOCATION equal facility LOCATION_CODE? Run `profiling/osr_mapping_join_check.sql` and send the CSV.
- [ ] R-MAP-003: Is Max Pax design capacity, permitted capacity or sellable beds?
- [ ] R-MAP-005: Is C003J101201 A at 3 pax deliberate, or should it be 6 like the other BB_Junior rooms?
- [ ] R-MAP-006: For the 462 split BB_Junior rooms, is the area on each A / B row that half's area, or the whole room repeated?
- [ ] R-MAP-008: Are C004S B1..B9 (with space) and C004SB1..B9 the same buildings?
- [ ] R-MAP-009: Should AA_Labour = Labour Small and BB_Junior = Junior be grouped as one room category in outputs?
- [ ] R-MAP-010: Is ASSIGNABLE AREA in square metres?
- [ ] R-MAP-011: Does mapping CLUSTER equal facility FACILITY_CLUSTER?

## Resolved

- [x] 2026-10-19 R-LIC-002: current-row flag is not a default (rejected).
- [x] 2026-10-19 R-LIC-009: JAFZA by organisation, all zones (superseded by R-LIC-016).
- [x] 2026-10-19 R-FAC-002: JAFZA facilities by organisation, keep all zones (confirmed).
- [x] 2026-10-19 R-FAC-003: leased = STATUS_GROUP Leased (confirmed).
- [x] 2026-10-19 R-REQ-004: activities column shows all activities (superseded by R-REQ-007).
