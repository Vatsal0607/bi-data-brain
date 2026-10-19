-- JAFZA leased facilities by product, one row per account (v3: adds LICENCE_TYPE and MATCHED_ACTIVITIES)
-- Accounts = accounts holding a qualifying JAFZA licence (exact or close activity match)
WITH
-- Exact names from the request (lower-case, de-duplicated)
ex AS (
  SELECT 'chemicals blending' AS nm
  UNION ALL SELECT 'composed industrial chemical manufacturing'
  UNION ALL SELECT 'basic industrial chemicals trading'
  UNION ALL SELECT 'industrial solvents trading'
  UNION ALL SELECT 'acids & alkaline trading'
  UNION ALL SELECT 'petrochemicals trading'
  UNION ALL SELECT 'fuel trading'
  UNION ALL SELECT 'refined oil products trading'
  UNION ALL SELECT 'production & distribution of gas'
  UNION ALL SELECT 'industrial & liquefied natural gas trading'
  UNION ALL SELECT 'gas liquefaction & bottling manufacturing'
  UNION ALL SELECT 'petroleum gas bottling'
  UNION ALL SELECT 'tanks cleaning services'
  UNION ALL SELECT 'gas station'
  UNION ALL SELECT 'fuel distribution'
  UNION ALL SELECT 'oil & natural gas pipelines contracting'
  UNION ALL SELECT 'fuel manufacturing'
  UNION ALL SELECT 'petrochemical manufacturing'
  UNION ALL SELECT 'waste & scrap handling & processing'
  UNION ALL SELECT 'electricity production'
),
-- Keywords for "closely matches" (edit freely; padded words match whole words only)
kw AS (
  SELECT 'chemical' AS k
  UNION ALL SELECT 'solvent'
  UNION ALL SELECT ' acid'
  UNION ALL SELECT 'alkal'
  UNION ALL SELECT 'blending'
  UNION ALL SELECT 'petro'
  UNION ALL SELECT 'fuel'
  UNION ALL SELECT 'refin'
  UNION ALL SELECT ' gas '
  UNION ALL SELECT ' oil '
  UNION ALL SELECT ' lng '
  UNION ALL SELECT ' lpg '
  UNION ALL SELECT 'liquef'
  UNION ALL SELECT 'bottling'
  UNION ALL SELECT 'tank'
  UNION ALL SELECT 'pipeline'
  UNION ALL SELECT 'waste'
  UNION ALL SELECT 'scrap'
  UNION ALL SELECT 'electricity'
  UNION ALL SELECT 'power gener'
),
acts AS (
  SELECT DISTINCT TRIM(LICENSE_ACTIVITY_DESCRIPTION) AS act
  FROM DPW_DL.T_DA_CX_LICENSE_MASTER
  WHERE LICENSE_ACTIVITY_DESCRIPTION IS NOT NULL
),
act_class AS (
  SELECT a.act,
         CASE WHEN MAX(CASE WHEN LOWER(a.act) = e.nm THEN 1 ELSE 0 END) = 1 THEN 'EXACT'
              WHEN MAX(CASE WHEN LOWER(' ' || a.act || ' ') LIKE '%' || k.k || '%' THEN 1 ELSE 0 END) = 1 THEN 'CLOSE'
              ELSE 'OTHER' END AS match_type
  FROM acts a CROSS JOIN ex e CROSS JOIN kw k
  GROUP BY a.act
),
-- Licence rows in scope (same logic as the licence query)
cur AS (
  SELECT LICENSE_NUMBER, ACCOUNT_NUMBER, ACCOUNT_NAME, LICENSE_TYPE,
         TRIM(LICENSE_ACTIVITY_DESCRIPTION) AS act
  FROM DPW_DL.T_DA_CX_LICENSE_MASTER
  WHERE ZONE_NAME = 'Jebel Ali Free Zone'            -- CONFIRM licence zone logic
    AND LIC_STATUS_OLD_FLAG = 'N'                    -- delete this line to use raw rows
    AND LICENSE_ACTIVITY_DESCRIPTION IS NOT NULL
    AND ACCOUNT_NUMBER IS NOT NULL
    AND LICENSE_STATUS IN ('Active','Alive','Awaiting Amendment','Awaiting Conversion',
                           'Awaiting Creation','Awaiting Freeze','Awaiting Liquidation-TBA',
                           'Awaiting Renewal','Awaiting Termination','Expired')
    AND REG_STATUS IN ('Active','Awaiting Amendment','Awaiting Conversion','Awaiting Freeze',
                       'Awaiting Renewal','Awaiting Termination','De Registered','Frozen')
),
-- One row per account that holds at least one exact or close activity
accts AS (
  SELECT c.ACCOUNT_NUMBER,
         MAX(c.ACCOUNT_NAME) AS ACCOUNT_NAME,
         MAX(CASE WHEN ac.match_type = 'EXACT' THEN 1 ELSE 0 END) AS has_exact,
         MAX(CASE WHEN ac.match_type = 'CLOSE' THEN 1 ELSE 0 END) AS has_close
  FROM cur c JOIN act_class ac ON ac.act = c.act
  WHERE ac.match_type IN ('EXACT','CLOSE')
  GROUP BY c.ACCOUNT_NUMBER
),
-- Distinct matched activities per account (exact first, then close), joined with commas
acct_act AS (
  SELECT DISTINCT c.ACCOUNT_NUMBER, c.act, ac.match_type
  FROM cur c JOIN act_class ac ON ac.act = c.act
  WHERE ac.match_type IN ('EXACT','CLOSE')
),
acct_rank AS (
  SELECT ACCOUNT_NUMBER, act, match_type,
         ROW_NUMBER() OVER (PARTITION BY ACCOUNT_NUMBER
                            ORDER BY CASE WHEN match_type = 'EXACT' THEN 0 ELSE 1 END, act) AS rn
  FROM acct_act
),
acct_str AS (
  SELECT ACCOUNT_NUMBER, COUNT(*) AS n_act,
      COALESCE(MAX(CASE WHEN rn = 1 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 2 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 3 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 4 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 5 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 6 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 7 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 8 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 9 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 10 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 11 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 12 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 13 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 14 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 15 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 16 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 17 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 18 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 19 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 20 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 21 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 22 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 23 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 24 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 25 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 26 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 27 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 28 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 29 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 30 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 31 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 32 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 33 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 34 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 35 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 36 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 37 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 38 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 39 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 40 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 41 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 42 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 43 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 44 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 45 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 46 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 47 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 48 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 49 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 50 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 51 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 52 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 53 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 54 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 55 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 56 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 57 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 58 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 59 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      || COALESCE(MAX(CASE WHEN rn = 60 THEN ', ' || act || CASE WHEN match_type = 'CLOSE' THEN ' [close]' ELSE '' END END), '')
      AS raw_list
  FROM acct_rank
  GROUP BY ACCOUNT_NUMBER
),
-- Distinct licence types per account (from the licences that matched), joined with commas
acct_type AS (
  SELECT DISTINCT c.ACCOUNT_NUMBER, TRIM(c.LICENSE_TYPE) AS LICENSE_TYPE
  FROM cur c JOIN act_class ac ON ac.act = c.act
  WHERE ac.match_type IN ('EXACT','CLOSE')
    AND c.LICENSE_TYPE IS NOT NULL AND TRIM(c.LICENSE_TYPE) <> ''
),
type_rank AS (
  SELECT ACCOUNT_NUMBER, LICENSE_TYPE,
         ROW_NUMBER() OVER (PARTITION BY ACCOUNT_NUMBER ORDER BY LICENSE_TYPE) AS rn
  FROM acct_type
),
type_str AS (
  SELECT ACCOUNT_NUMBER, COUNT(*) AS n_type,
      COALESCE(MAX(CASE WHEN rn = 1 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 2 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 3 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 4 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 5 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 6 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 7 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 8 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 9 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 10 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 11 THEN ', ' || LICENSE_TYPE END), '')
      || COALESCE(MAX(CASE WHEN rn = 12 THEN ', ' || LICENSE_TYPE END), '')
      AS raw_types
  FROM type_rank
  GROUP BY ACCOUNT_NUMBER
),
-- Leased JAFZA facilities (one row per facility / LOCATION_CODE)
fac AS (
  SELECT ACCOUNT_NO, LOCATION_CODE, TRIM(PRODUCT_SPACE_TYPE) AS product
  FROM DPW_DL.T_DA_CX_CURR_FACILITY_INFO
  WHERE ORGANIZATION_NAME = 'JAFZA'                  -- CONFIRM JAFZA definition
    AND STATUS_GROUP = 'Leased'                      -- Leased, Under Renewal, Under Legal, Under Termination
    AND ACCOUNT_NO IS NOT NULL AND TRIM(ACCOUNT_NO) <> ''
)
SELECT a.ACCOUNT_NUMBER,
       a.ACCOUNT_NAME,
       CASE WHEN t.n_type > 12 THEN SUBSTR(t.raw_types, 3) || ', ...'
            ELSE SUBSTR(t.raw_types, 3) END AS LICENCE_TYPE,
       CASE WHEN a.has_exact = 1 AND a.has_close = 1 THEN 'EXACT + CLOSE'
            WHEN a.has_exact = 1 THEN 'EXACT'
            ELSE 'CLOSE' END AS LICENCE_MATCH_TYPE,
       CASE WHEN s.n_act > 60 THEN SUBSTR(s.raw_list, 3) || ', ...'
            ELSE SUBSTR(s.raw_list, 3) END AS MATCHED_ACTIVITIES,   -- close matches tagged [close]
       COUNT(DISTINCT f.LOCATION_CODE) AS TOTAL_FACILITIES,
       COUNT(DISTINCT CASE WHEN f.product = '1 Plot'            THEN f.LOCATION_CODE END) AS PLOT,
       COUNT(DISTINCT CASE WHEN f.product = '2 LIU Warehouse'   THEN f.LOCATION_CODE END) AS LIU_WAREHOUSE,
       COUNT(DISTINCT CASE WHEN f.product = '3 Showroom'        THEN f.LOCATION_CODE END) AS SHOWROOM,
       COUNT(DISTINCT CASE WHEN f.product = '4 Office'          THEN f.LOCATION_CODE END) AS OFFICE,
       COUNT(DISTINCT CASE WHEN f.product = '5 Workstation'     THEN f.LOCATION_CODE END) AS WORKSTATION,
       COUNT(DISTINCT CASE WHEN f.product = '6 Retail'          THEN f.LOCATION_CODE END) AS RETAIL,
       COUNT(DISTINCT CASE WHEN f.product = '7 OSR'             THEN f.LOCATION_CODE END) AS OSR,
       COUNT(DISTINCT CASE WHEN f.product IS NULL
                             OR f.product NOT IN ('1 Plot','2 LIU Warehouse','3 Showroom',
                                                  '4 Office','5 Workstation','6 Retail','7 OSR')
                           THEN f.LOCATION_CODE END) AS OTHER_PRODUCTS
FROM accts a
JOIN fac f ON f.ACCOUNT_NO = a.ACCOUNT_NUMBER        -- inner join: accounts with no JAFZA lease drop out
JOIN acct_str s ON s.ACCOUNT_NUMBER = a.ACCOUNT_NUMBER
LEFT JOIN type_str t ON t.ACCOUNT_NUMBER = a.ACCOUNT_NUMBER
GROUP BY a.ACCOUNT_NUMBER, a.ACCOUNT_NAME, a.has_exact, a.has_close, s.n_act, s.raw_list, t.n_type, t.raw_types
ORDER BY CASE WHEN a.has_exact = 1 AND a.has_close = 0 THEN 1   -- EXACT only
              WHEN a.has_exact = 1 THEN 2                        -- EXACT + CLOSE
              ELSE 3 END,                                        -- CLOSE only
         COUNT(DISTINCT f.LOCATION_CODE) DESC, a.ACCOUNT_NAME;
