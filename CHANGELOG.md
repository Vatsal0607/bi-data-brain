# Changelog

Newest first. One line per rule change or structural change.

## 2026-10-19 (answers to open questions)
- R-LIC-002 REJECTED as default. New default scope R-LIC-014: Active and Alive licences, no current-row flag.
- R-LIC-007 / R-LIC-008 re-scoped to the 2026-10-16 request only; R-LIC-015 added (no default registration-status filter, assumption).
- R-LIC-009 SUPERSEDED by R-LIC-016: JAFZA licences identified by ORG_NAME, all zones. R-LIC-017 added: exact ORG_NAME value still to be verified.
- R-FAC-002 and R-FAC-003 now USER-CONFIRMED.
- R-REQ-004 SUPERSEDED by R-REQ-007: show all activities, tagged [exact] / [close]. R-REQ-005 widened to all in-scope licences of the account. R-REQ-006 and R-REQ-008 added (organisation includes all zones; request-specific filters never become defaults).
- Queries 01 to 03 regenerated to the new defaults; ALL_ACTIVITIES replaces MATCHED_ACTIVITIES. Added `profiling/license_master_profile.sql`.

## 2026-10-19
- Repo created. Seeded from the JAFZA chemicals / fuel / gas / oil / waste request (rules R-LIC-*, R-FAC-*, R-REQ-*, R-SQL-*).
- R-LIC-004 REJECTED: `IS_PREFERRED = 1` as the current-row rule drops too many licences.
- R-SQL-001 added: LISTAGG unavailable, slot-pivot pattern adopted.
