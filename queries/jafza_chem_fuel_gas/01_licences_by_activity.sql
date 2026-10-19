-- JAFZA activity match: one row per licence (no LISTAGG; plain-SQL pivot)
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
-- Classify every distinct activity description once
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
-- Rows in scope: JAFZA organisation (all zones), Active / Alive licences
cur AS (
  SELECT SUR_GKEY, LICENSE_NUMBER, ACCOUNT_NUMBER, ACCOUNT_NAME, ORG_NAME, ZONE_NAME,
         LICENSE_STATUS, REG_STATUS, BI_CREATED,
         TRIM(LICENSE_ACTIVITY_DESCRIPTION) AS act
  FROM DPW_DL.T_DA_CX_LICENSE_MASTER
  WHERE ORG_NAME = 'JAFZA'                           -- CONFIRM R-LIC-017: exact ORG_NAME value; all zones included (R-LIC-016)
    AND LICENSE_STATUS IN ('Active','Alive')         -- default licence scope (R-LIC-014); no current-row flag (R-LIC-002)
    AND LICENSE_ACTIVITY_DESCRIPTION IS NOT NULL
),
lic_act AS (
  SELECT DISTINCT c.LICENSE_NUMBER, c.act, ac.match_type
  FROM cur c JOIN act_class ac ON ac.act = c.act
),
lic_rank AS (
  SELECT LICENSE_NUMBER, act, match_type,
         ROW_NUMBER() OVER (PARTITION BY LICENSE_NUMBER ORDER BY act) AS rn_all,
         ROW_NUMBER() OVER (PARTITION BY LICENSE_NUMBER, match_type ORDER BY act) AS rn_type
  FROM lic_act
),
hits AS (
  SELECT LICENSE_NUMBER FROM lic_act
  WHERE match_type IN ('EXACT','CLOSE')
  GROUP BY LICENSE_NUMBER
),
-- One header row per licence (latest row wins if attributes differ)
hdr AS (
  SELECT LICENSE_NUMBER, ACCOUNT_NUMBER, ACCOUNT_NAME, ORG_NAME, ZONE_NAME, LICENSE_STATUS, REG_STATUS
  FROM (
    SELECT c.*, ROW_NUMBER() OVER (PARTITION BY c.LICENSE_NUMBER
                                   ORDER BY c.BI_CREATED DESC, c.SUR_GKEY DESC) AS rn
    FROM cur c JOIN hits h ON h.LICENSE_NUMBER = c.LICENSE_NUMBER
  ) t
  WHERE rn = 1
),
-- Plain-SQL string aggregation: one slot per activity, concatenated
agg AS (
  SELECT LICENSE_NUMBER,
    SUM(CASE WHEN match_type = 'EXACT' THEN 1 ELSE 0 END) AS n_exact,
    SUM(CASE WHEN match_type = 'CLOSE' THEN 1 ELSE 0 END) AS n_close,
    COUNT(*) AS n_all,
    COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 1 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 2 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 3 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 4 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 5 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 6 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 7 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 8 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 9 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 10 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 11 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 12 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 13 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 14 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 15 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 16 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 17 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 18 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 19 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'EXACT' AND rn_type = 20 THEN ', ' || act END), '')
      AS exact_raw,
    COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 1 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 2 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 3 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 4 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 5 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 6 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 7 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 8 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 9 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 10 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 11 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 12 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 13 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 14 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 15 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 16 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 17 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 18 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 19 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 20 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 21 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 22 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 23 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 24 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 25 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 26 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 27 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 28 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 29 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 30 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 31 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 32 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 33 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 34 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 35 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 36 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 37 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 38 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 39 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN match_type = 'CLOSE' AND rn_type = 40 THEN ', ' || act END), '')
      AS close_raw,
    COALESCE(MAX(CASE WHEN rn_all = 1 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 2 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 3 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 4 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 5 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 6 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 7 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 8 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 9 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 10 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 11 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 12 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 13 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 14 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 15 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 16 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 17 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 18 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 19 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 20 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 21 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 22 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 23 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 24 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 25 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 26 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 27 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 28 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 29 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 30 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 31 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 32 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 33 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 34 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 35 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 36 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 37 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 38 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 39 THEN ', ' || act END), '')
      || COALESCE(MAX(CASE WHEN rn_all = 40 THEN ', ' || act END), '')
      AS all_raw
  FROM lic_rank
  WHERE LICENSE_NUMBER IN (SELECT LICENSE_NUMBER FROM hits)
  GROUP BY LICENSE_NUMBER
)
SELECT h.LICENSE_NUMBER, h.ACCOUNT_NUMBER, h.ACCOUNT_NAME, h.ORG_NAME, h.ZONE_NAME,
       h.LICENSE_STATUS, h.REG_STATUS,
       CASE WHEN a.n_exact > 0 AND a.n_close > 0 THEN 'EXACT + CLOSE'
            WHEN a.n_exact > 0 THEN 'EXACT'
            ELSE 'CLOSE' END AS MATCH_TYPE,
       NULLIF(SUBSTR(a.exact_raw, 3), '') AS EXACT_MATCH_ACTIVITIES,
       NULLIF(SUBSTR(a.close_raw, 3), '') AS CLOSE_MATCH_ACTIVITIES,
       NULLIF(SUBSTR(a.all_raw, 3), '')   AS ALL_LICENSE_ACTIVITIES
FROM hdr h JOIN agg a ON a.LICENSE_NUMBER = h.LICENSE_NUMBER
ORDER BY h.ACCOUNT_NAME, h.LICENSE_NUMBER;
