-- Profiling pack for DPW_DL.T_DA_CX_LICENSE_MASTER. Run each query separately in DBeaver and send the output.
-- Each result feeds tables/T_DA_CX_LICENSE_MASTER.md and the rules. Standard SQL; the catalog query (7) needs checking on your Vertica version.

-- 1. Organisation x zone (finds the exact JAFZA ORG_NAME value, R-LIC-017)
SELECT ORG_NAME, ZONE_NAME, COUNT(*) AS n_rows, COUNT(DISTINCT LICENSE_NUMBER) AS n_licences
FROM DPW_DL.T_DA_CX_LICENSE_MASTER
GROUP BY ORG_NAME, ZONE_NAME
ORDER BY n_licences DESC;

-- 2. Licence status
SELECT LICENSE_STATUS, COUNT(*) AS n_rows, COUNT(DISTINCT LICENSE_NUMBER) AS n_licences
FROM DPW_DL.T_DA_CX_LICENSE_MASTER
GROUP BY LICENSE_STATUS ORDER BY n_licences DESC;

-- 3. Registration status
SELECT REG_STATUS, COUNT(*) AS n_rows, COUNT(DISTINCT LICENSE_NUMBER) AS n_licences
FROM DPW_DL.T_DA_CX_LICENSE_MASTER
GROUP BY REG_STATUS ORDER BY n_licences DESC;

-- 4. Licence type
SELECT LICENSE_TYPE, COUNT(*) AS n_rows, COUNT(DISTINCT LICENSE_NUMBER) AS n_licences
FROM DPW_DL.T_DA_CX_LICENSE_MASTER
GROUP BY LICENSE_TYPE ORDER BY n_licences DESC;

-- 5. What do the old / preferred flags mean? (R-LIC-002, R-LIC-004)
SELECT LIC_STATUS_OLD_FLAG, IS_PREFERRED, LICENSE_STATUS, COUNT(*) AS n_rows, COUNT(DISTINCT LICENSE_NUMBER) AS n_licences
FROM DPW_DL.T_DA_CX_LICENSE_MASTER
GROUP BY LIC_STATUS_OLD_FLAG, IS_PREFERRED, LICENSE_STATUS
ORDER BY n_licences DESC;

-- 6. Active / Alive licences by organisation (default scope, R-LIC-014)
SELECT ORG_NAME, COUNT(DISTINCT LICENSE_NUMBER) AS n_licences, COUNT(DISTINCT ACCOUNT_NUMBER) AS n_accounts
FROM DPW_DL.T_DA_CX_LICENSE_MASTER
WHERE LICENSE_STATUS IN ('Active','Alive')
GROUP BY ORG_NAME ORDER BY n_licences DESC;

-- 7. All columns (verify catalog view name on your Vertica)
SELECT column_name, data_type, ordinal_position
FROM v_catalog.columns
WHERE table_schema = 'DPW_DL' AND table_name = 'T_DA_CX_LICENSE_MASTER'
ORDER BY ordinal_position;

-- 8. Top 100 activity descriptions by licences (Active / Alive)
SELECT TRIM(LICENSE_ACTIVITY_DESCRIPTION) AS activity, COUNT(DISTINCT LICENSE_NUMBER) AS n_licences
FROM DPW_DL.T_DA_CX_LICENSE_MASTER
WHERE LICENSE_STATUS IN ('Active','Alive')
GROUP BY TRIM(LICENSE_ACTIVITY_DESCRIPTION)
ORDER BY n_licences DESC
LIMIT 100;
