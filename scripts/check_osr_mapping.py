"""Check the OSR PAX mapping file, and optionally compare it with a facility export.

Usage:
  python3 scripts/check_osr_mapping.py <mapping.xlsx> --selftest
  python3 scripts/check_osr_mapping.py <mapping.xlsx> <facility_osr.csv>

--selftest  re-profiles the file and tests the R-MAP-004 pax expression against it.
CSV         output of profiling/osr_mapping_join_check.sql; reports match rates for
            R-MAP-002 (location), R-MAP-004 (function type) and R-MAP-011 (cluster).
Needs openpyxl. Prints aggregates only.
"""
import collections
import csv
import sys

import openpyxl

BASE = {"Labour Big": 12, "AA_Labour": 8, "Labour Small": 8, "Junior": 6, "BB_Junior": 6,
        "CC_Senior": 6, "C_Senior": 6, "Senior": 3, "Executive - 2 BR": 4,
        "Executive - 1 BR (BIG)": 2, "Executive - 1 BR (SMALL)": 2, "Executive - Studio": 2}
EB04 = {"Executive - 2 BR": 7, "Executive - 1 BR (BIG)": 5, "Executive - 1 BR (SMALL)": 5,
        "Executive - Studio": 3}


def pax_rule(function_type, building):
    """R-MAP-004."""
    if building == "S2C2EB04" and function_type in EB04:
        return EB04[function_type]
    return BASE.get(function_type)


def load_mapping(path):
    ws = openpyxl.load_workbook(path, read_only=True, data_only=True).worksheets[0]
    rows = ws.iter_rows(values_only=True)
    head = [str(h).strip() for h in next(rows)]
    return [dict(zip(head, r)) for r in rows if any(v is not None for v in r)]


def norm(s):
    return " ".join(str(s or "").split())


def selftest(m):
    locs = [r["LOCATION"] for r in m]
    print("rows", len(m), "unique LOCATION", len(set(locs)))
    for col in ["SPACE_TYPE", "PRODUCT", "ORGANIZATION_NAME", "ZONE_NAME", "CLUSTER", "FUNCTION_TYPE"]:
        print(col, dict(collections.Counter(r[col] for r in m).most_common()))
    bad = [r for r in m if pax_rule(r["FUNCTION_TYPE"], r["BUILDING"]) != r["Max Pax"]]
    print("R-MAP-004 expression reproduces %d of %d rows" % (len(m) - len(bad), len(m)))
    for r in bad[:20]:
        print("  exception:", r["LOCATION"], r["FUNCTION_TYPE"], r["Max Pax"])
    print("total Max Pax", sum(r["Max Pax"] for r in m),
          "total area", round(sum(r["ASSIGNABLE AREA"] for r in m), 2))


def compare(m, csv_path):
    with open(csv_path, newline="", encoding="utf-8-sig") as fh:
        f = list(csv.DictReader(fh))
    f = {r["LOCATION_CODE"]: r for r in f if r.get("LOCATION_CODE")}
    mk = {r["LOCATION"]: r for r in m}
    both = set(f) & set(mk)
    print("mapping locations", len(mk), "facility rows", len(f), "exact matches", len(both))
    stripped = {k.replace(" ", ""): k for k in f}
    extra = [k for k in set(mk) - both if k.replace(" ", "") in stripped]
    print("further matches only after removing spaces", len(extra))
    print("mapping-only examples", sorted(set(mk) - both)[:10])
    print("facility-only examples", sorted(set(f) - both)[:10])
    ft = collections.Counter((mk[k]["FUNCTION_TYPE"] == f[k].get("FUNCTION_TYPE")) for k in both)
    print("FUNCTION_TYPE equal on matched rows", ft[True], "differ", ft[False])
    if ft[False]:
        diff = collections.Counter((mk[k]["FUNCTION_TYPE"], f[k].get("FUNCTION_TYPE")) for k in both
                                   if mk[k]["FUNCTION_TYPE"] != f[k].get("FUNCTION_TYPE"))
        print("  top differences (mapping, facility)", diff.most_common(10))
    cl = collections.Counter((norm(mk[k]["CLUSTER"]), norm(f[k].get("FACILITY_CLUSTER"))) for k in both)
    print("CLUSTER vs FACILITY_CLUSTER pairs", cl.most_common(15))


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    mapping = load_mapping(sys.argv[1])
    if sys.argv[2] == "--selftest":
        selftest(mapping)
    else:
        compare(mapping, sys.argv[2])
