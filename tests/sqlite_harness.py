"""Regression test of delivered queries on synthetic data in SQLite.

Proves query LOGIC only. SQLite does not validate Vertica-specific syntax.
Add a case here whenever a rule changes or a new delivered query is added.
"""
import pathlib
import sqlite3
import sys

root = pathlib.Path(__file__).resolve().parent.parent
Q = root / "queries" / "jafza_chem_fuel_gas"
Z = "Jebel Ali Free Zone"


def load():
    db = sqlite3.connect(":memory:")
    db.execute("ATTACH ':memory:' AS DPW_DL")
    db.execute("""CREATE TABLE DPW_DL.T_DA_CX_LICENSE_MASTER (
        SUR_GKEY INT, LICENSE_NUMBER TEXT, ACCOUNT_NUMBER TEXT, ACCOUNT_NAME TEXT, ORG_NAME TEXT,
        ZONE_NAME TEXT, LICENSE_STATUS TEXT, REG_STATUS TEXT, LICENSE_ACTIVITY_DESCRIPTION TEXT,
        LIC_STATUS_OLD_FLAG TEXT, BI_CREATED TEXT, LICENSE_TYPE TEXT)""")
    db.execute("""CREATE TABLE DPW_DL.T_DA_CX_CURR_FACILITY_INFO (
        SUR_GKEY INT, LOCATION_CODE TEXT, ACCOUNT_NO TEXT, ORGANIZATION_NAME TEXT, ZONE_NAME TEXT,
        STATUS_GROUP TEXT, STATUS TEXT, PRODUCT_SPACE_TYPE TEXT, SPACE_TYPE TEXT)""")
    # lic, account, name, activity, type, licence status, flag
    lic = [
        ("L1", "A1", "Alpha", "Scrap Metal Trading", "Industrial", "Active", "N"),   # CLOSE
        ("L2", "A2", "Beta", "Fuel Trading", "Trading", "Active", "N"),              # EXACT
        ("L3", "A3", "Gamma", "Fuel Trading", "Trading", "Active", "N"),             # EXACT
        ("L3", "A3", "Gamma", "Scrap Metal Trading", "Trading", "Active", "N"),      # + CLOSE
        ("L4", "A3", "Gamma", "Fuel Trading", "Services", "Active", "N"),            # 2nd type
        ("L5", "A4", "Delta", "Software Development", "Trading", "Active", "N"),     # no match
        ("L6", "A5", "Epsilon", "Fuel Trading", "Trading", "Terminated", "N"),       # status out
        ("L7", "A6", "Zeta", "Fuel Trading", "Trading", "Active", "Y"),              # old row
    ]
    for i, (l, a, n, act, t, st, fl) in enumerate(lic):
        db.execute("INSERT INTO DPW_DL.T_DA_CX_LICENSE_MASTER VALUES (?,?,?,?,'JAFZA',?,?,'Active',?,?, 'x', ?)",
                   (i, l, a, n, Z, st, act, fl, t))
    fac = [  # account, group, status, product, space, org
        ("A1", "Leased", "Leased", "1 Plot", "Plot", "JAFZA"),
        ("A1", "Leased", "Under Renewal", "1 Plot", "Plot", "JAFZA"),
        ("A1", "Under Amendment", "Under Amendment", "1 Plot", "Plot", "JAFZA"),   # not leased
        ("A2", "Leased", "Leased", "7 OSR", "Open", "JAFZA"),
        ("A2", "Leased", "Leased", "7 OSR", "Open", "National Industries Park"),   # not JAFZA
        ("A3", "Leased", "Leased", "2 LIU Warehouse", "Warehouse", "JAFZA"),
        ("A3", "Leased", "Leased", "4 Office", "Office", "JAFZA"),
        ("A3", "Vacant", "Vacant", "4 Office", "Office", "JAFZA"),                 # not leased
        ("A4", "Leased", "Leased", "4 Office", "Office", "JAFZA"),                 # no matching licence
        ("A7", "Leased", "Leased", "4 Office", "Office", "JAFZA"),                 # no licence at all
    ]
    for i, (a, g, s, p, sp, org) in enumerate(fac):
        db.execute("INSERT INTO DPW_DL.T_DA_CX_CURR_FACILITY_INFO VALUES (?,?,?,?,'Jafza North',?,?,?,?)",
                   (i, "LOC%d" % i, a, org, g, s, p, sp))
    return db


def run(db, name):
    sql = (Q / name).read_text().rstrip().rstrip(";")
    cur = db.execute(sql)
    cols = [d[0] for d in cur.description]
    return [dict(zip(cols, r)) for r in cur.fetchall()]


def check(cond, msg):
    if not cond:
        print("FAIL:", msg)
        sys.exit(1)
    print("ok:", msg)


db = load()

rows = run(db, "01_licences_by_activity.sql")
m = {r["LICENSE_NUMBER"]: r["MATCH_TYPE"] for r in rows}
check(m == {"L1": "CLOSE", "L2": "EXACT", "L3": "EXACT + CLOSE", "L4": "EXACT"},
      "licence query: match types, excludes no-match / bad status / old rows (R-LIC-002, R-LIC-007, R-LIC-010)")

rows = run(db, "02_facility_summary_by_account.sql")
check([r["ACCOUNT_NUMBER"] for r in rows] == ["A2", "A3", "A1"],
      "summary: exact first, then exact+close, then close (R-REQ-003)")
a3 = next(r for r in rows if r["ACCOUNT_NUMBER"] == "A3")
check(a3["TOTAL_FACILITIES"] == 2 and a3["LIU_WAREHOUSE"] == 1 and a3["OFFICE"] == 1,
      "summary: A3 counts only leased facilities (R-FAC-003)")
check(a3["LICENCE_TYPE"] == "Services, Trading", "summary: licence types combined per account (R-REQ-005)")
check(next(r for r in rows if r["ACCOUNT_NUMBER"] == "A2")["TOTAL_FACILITIES"] == 1,
      "summary: non-JAFZA organisation excluded (R-FAC-002)")
check(next(r for r in rows if r["ACCOUNT_NUMBER"] == "A1")["TOTAL_FACILITIES"] == 2,
      "summary: Under Amendment excluded (R-FAC-003)")
check({r["ACCOUNT_NUMBER"] for r in rows} == {"A1", "A2", "A3"},
      "summary: accounts without a matching licence or JAFZA lease drop out (R-REQ-001)")

rows = run(db, "03_facility_list_by_location.sql")
check(len(rows) == 5, "list: one row per leased facility, equal to summary totals")
check(list(rows[0].keys()) == ["ACCOUNT_NUMBER", "ACCOUNT_NAME", "LICENSE_TYPE", "LICENSE_MATCH_TYPE",
                               "PRODUCT", "SPACE_TYPE", "LOCATION_ID"], "list: column order")
check([r["ACCOUNT_NUMBER"] for r in rows] == ["A2", "A3", "A3", "A1", "A1"], "list: sort order (R-REQ-003)")
check(len({r["LOCATION_ID"] for r in rows}) == 5, "list: location IDs unique (R-FAC-001)")
print("all tests passed")
