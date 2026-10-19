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
    # lic, account, name, activity, type, licence status, flag, org, zone
    J, Zn = "JAFZA", Z
    lic = [
        ("L1", "A1", "Alpha", "Scrap Metal Trading", "Industrial", "Active", "N", J, Zn),     # CLOSE
        ("L2", "A2", "Beta", "Fuel Trading", "Trading", "Active", "N", J, Zn),                # EXACT
        ("L3", "A3", "Gamma", "Fuel Trading", "Trading", "Alive", "N", J, Zn),                # EXACT (Alive counts)
        ("L3", "A3", "Gamma", "Scrap Metal Trading", "Trading", "Alive", "N", J, Zn),         # + CLOSE
        ("L4", "A3", "Gamma", "Fuel Trading", "Services", "Active", "N", J, Zn),              # 2nd type
        ("L5", "A4", "Delta", "Software Development", "Trading", "Active", "N", J, Zn),       # no match
        ("L6", "A5", "Epsilon", "Fuel Trading", "Trading", "Terminated", "N", J, Zn),         # status out
        ("L7", "A6", "Zeta", "Fuel Trading", "Trading", "Active", "Y", J, Zn),                # old flag must NOT exclude (R-LIC-002)
        ("L8", "A8", "Theta", "Fuel Trading", "Trading", "Active", "N", "National Industries Park", "NIP"),  # other org
        ("L9", "A9", "Iota", "Fuel Trading", "Trading", "Active", "N", J, "Another JAFZA Zone"),  # all zones count (R-LIC-016)
        ("L10", "A2", "Beta", "Software Development", "Holding", "Active", "N", J, Zn),       # unmatched activity + extra type
    ]
    for i, (l, a, n, act, t, st, fl, org, zn) in enumerate(lic):
        db.execute("INSERT INTO DPW_DL.T_DA_CX_LICENSE_MASTER VALUES (?,?,?,?,?,?,?,'Active',?,?, 'x', ?)",
                   (i, l, a, n, org, zn, st, act, fl, t))
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
        ("A9", "Leased", "Under Legal", "6 Retail", "Retail", "JAFZA"),            # Under Legal is leased
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
check(m == {"L1": "CLOSE", "L2": "EXACT", "L3": "EXACT + CLOSE", "L4": "EXACT", "L7": "EXACT", "L9": "EXACT"},
      "licence query: Active/Alive only, old flag ignored, all JAFZA zones, other orgs out (R-LIC-014, R-LIC-002, R-LIC-016)")

rows = run(db, "02_facility_summary_by_account.sql")
check([r["ACCOUNT_NUMBER"] for r in rows] == ["A2", "A9", "A3", "A1"],
      "summary: exact first, then exact+close, then close; facilities desc then name (R-REQ-003)")
by = {r["ACCOUNT_NUMBER"]: r for r in rows}
check(by["A3"]["TOTAL_FACILITIES"] == 2 and by["A3"]["LIU_WAREHOUSE"] == 1 and by["A3"]["OFFICE"] == 1,
      "summary: A3 counts only leased facilities (R-FAC-003)")
check(by["A9"]["TOTAL_FACILITIES"] == 1 and by["A9"]["RETAIL"] == 1, "summary: Under Legal counts as leased (R-FAC-003)")
check(by["A3"]["LICENCE_TYPE"] == "Services, Trading", "summary: licence types combined per account (R-REQ-005)")
check(by["A2"]["LICENCE_TYPE"] == "Holding, Trading", "summary: types include non-matching licences of the account (R-REQ-005)")
check(by["A2"]["ALL_ACTIVITIES"] == "Fuel Trading [exact], Software Development",
      "summary: all activities shown, matches tagged, exact first (R-REQ-007)")
check(by["A3"]["ALL_ACTIVITIES"] == "Fuel Trading [exact], Scrap Metal Trading [close]", "summary: A3 activities")
check(by["A2"]["TOTAL_FACILITIES"] == 1, "summary: non-JAFZA facility organisation excluded (R-FAC-002)")
check(by["A1"]["TOTAL_FACILITIES"] == 2, "summary: Under Amendment excluded (R-FAC-003)")
check(set(by) == {"A1", "A2", "A3", "A9"},
      "summary: accounts without a matching licence or JAFZA lease drop out (R-REQ-001)")

rows = run(db, "03_facility_list_by_location.sql")
check(len(rows) == 6, "list: one row per leased facility, equal to summary totals")
check(list(rows[0].keys()) == ["ACCOUNT_NUMBER", "ACCOUNT_NAME", "LICENSE_TYPE", "LICENSE_MATCH_TYPE",
                               "PRODUCT", "SPACE_TYPE", "LOCATION_ID"], "list: column order")
check([r["ACCOUNT_NUMBER"] for r in rows] == ["A2", "A9", "A3", "A3", "A1", "A1"], "list: sort order (R-REQ-003)")
check(len({r["LOCATION_ID"] for r in rows}) == 6, "list: location IDs unique (R-FAC-001)")
print("all tests passed")
