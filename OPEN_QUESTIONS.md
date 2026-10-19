# Open questions

Each `ASSUMPTION` rule must appear here until a human confirms or rejects it. Format: `- [ ] R-XXX-NNN: question`. Tick and move to CHANGELOG when resolved.

- [ ] R-LIC-002: Is `LIC_STATUS_OLD_FLAG = 'N'` the correct current-row filter for the licence master?
- [ ] R-LIC-009: Is JAFZA at licence level `ZONE_NAME = 'Jebel Ali Free Zone'`, or should it use `ORG_NAME`? Alignment check (profile ORG_NAME x ZONE_NAME) was sent but no result is recorded.
- [ ] R-LIC-011: Is the proposed close-match keyword list right (and complete)?
- [ ] R-FAC-002: Does "JAFZA" on the facility side mean `ORGANIZATION_NAME = 'JAFZA'` (which includes Jafza North, Jafza South, TechnoPark, Emaar, Limitless and others)?
- [ ] R-FAC-003: Does "leased" mean `STATUS_GROUP = 'Leased'` (includes Under Renewal, Under Legal, Under Termination)?
- [ ] R-REQ-004: Should MATCHED_ACTIVITIES show matched activities only (current) or all activities on the licence?
- [ ] R-REQ-005: Is a combined, comma-separated licence type per account the right treatment when an account holds several types?
