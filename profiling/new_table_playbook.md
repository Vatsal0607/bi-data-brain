# Playbook: learning a new table

Run in DBeaver, paste CSV or screenshots back, and record findings in `tables/<TABLE>.md` and `rules/`. Replace `T` with the table name. Check the catalog query against your Vertica version before relying on it.

1. **Structure**
```sql
SELECT column_name, data_type, ordinal_position
FROM v_catalog.columns
WHERE table_schema = 'DPW_DL' AND table_name = 'T'
ORDER BY ordinal_position;
```
2. **Row count and candidate key uniqueness**
```sql
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT <candidate_key>) AS n_keys FROM DPW_DL.T;
```
3. **Rows per key (grain)**
```sql
SELECT n, COUNT(*) AS n_keys FROM (SELECT <key>, COUNT(*) AS n FROM DPW_DL.T GROUP BY <key>) x GROUP BY n ORDER BY n;
```
4. **Value profile of each status / type column**
```sql
SELECT <col>, COUNT(*) AS n_rows FROM DPW_DL.T GROUP BY <col> ORDER BY n_rows DESC;
```
5. **Within-key variation** (do status, zone or type change across rows of one key?)
```sql
SELECT COUNT(*) AS keys_with_variation FROM (
  SELECT <key> FROM DPW_DL.T GROUP BY <key> HAVING COUNT(DISTINCT <col>) > 1) x;
```
6. **Current-row candidates** (flags such as old / preferred): compare how many keys each candidate drops.
7. **Join check** to related tables on the proposed key: match rate, unmatched examples.
8. **Sample** 20 rows of a few keys with many rows.

After each step: update the table page, add or adjust rules (status `DATA-VERIFIED` until the user confirms), add a CHANGELOG line.
