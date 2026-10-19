# Join map

| From | To | Condition | Status | Notes |
|---|---|---|---|---|
| `T_DA_CX_CURR_FACILITY_INFO` | `T_DA_CX_LICENSE_MASTER` | `ACCOUNT_NO = ACCOUNT_NUMBER` | USER-CONFIRMED (R-FAC-005) | Join at account level, not licence level. Facilities with no `ACCOUNT_NO` drop out (R-FAC-007). |

Always aggregate the licence side to account level before joining to facilities, otherwise the licence x activity grain multiplies facility rows (R-LIC-001).
