"""Print a LISTAGG-free comma-join expression (R-SQL-001).

Usage: python3 scripts/gen_slot_pivot.py <value_expr> <slots>
Example: python3 scripts/gen_slot_pivot.py LICENSE_TYPE 12

Expects a CTE exposing a column `rn` = ROW_NUMBER() OVER (PARTITION BY <group> ORDER BY <value>).
Wrap the result with SUBSTR(<expr>, 3) to drop the leading ', ', and append ', ...' when the
group's COUNT(*) exceeds the slot cap.
"""
import sys

val = sys.argv[1]
n = int(sys.argv[2])
print("\n      || ".join(
    "COALESCE(MAX(CASE WHEN rn = %d THEN ', ' || %s END), '')" % (i, val) for i in range(1, n + 1)))
