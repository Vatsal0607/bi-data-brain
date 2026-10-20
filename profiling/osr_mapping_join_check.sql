-- Join check: OSR PAX mapping (Excel) against the facility table.
-- Tests R-MAP-002 (LOCATION = LOCATION_CODE), R-MAP-004 (FUNCTION_TYPE values) and R-MAP-011 (CLUSTER = FACILITY_CLUSTER).
-- Run in DBeaver, export the full result as CSV (with header), then:
--   python3 scripts/check_osr_mapping.py "OSR PAX mapping.xlsx" facility_osr.csv
-- No filter on status or account, so every OSR facility is compared. Output holds no customer names.

SELECT
    LOCATION_CODE,
    TRIM(PRODUCT_SPACE_TYPE) AS PRODUCT_SPACE_TYPE,
    FUNCTION_TYPE,
    FACILITY_CLUSTER,
    ZONE_NAME,
    ORGANIZATION_NAME,
    STATUS_GROUP
FROM DPW_DL.T_DA_CX_CURR_FACILITY_INFO
WHERE ORGANIZATION_NAME = 'JAFZA'
  AND (TRIM(PRODUCT_SPACE_TYPE) = '7 OSR' OR UPPER(SPACE_TYPE) LIKE '%ACCOM%')
ORDER BY LOCATION_CODE;
