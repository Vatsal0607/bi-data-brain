"""Lint the brain: rule structure, IDs, statuses, references, open-question coverage."""
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
STATUSES = {"USER-CONFIRMED", "DATA-VERIFIED", "ASSUMPTION", "REJECTED", "SUPERSEDED"}
FIELDS = ["Status", "Rule", "SQL", "Evidence", "Last verified"]
errors = []
rules = {}

for f in sorted((root / "rules").glob("*.md")):
    text = f.read_text()
    blocks = re.split(r"(?m)^### ", text)[1:]
    for b in blocks:
        head, _, body = b.partition("\n")
        m = re.match(r"(R-[A-Z]+-\d{3})\s+\S", head)
        if not m:
            errors.append("%s: bad rule heading %r" % (f.name, head))
            continue
        rid = m.group(1)
        if rid in rules:
            errors.append("duplicate rule id " + rid)
        fields = dict(re.findall(r"(?m)^- \*\*([^:*]+):\*\* (.*)$", body))
        for k in FIELDS:
            if k not in fields or not fields[k].strip():
                errors.append("%s: missing field %s" % (rid, k))
        st = fields.get("Status", "").strip()
        if st not in STATUSES:
            errors.append("%s: invalid status %r" % (rid, st))
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", fields.get("Last verified", "").strip()):
            errors.append("%s: Last verified must be YYYY-MM-DD" % rid)
        if st == "SUPERSEDED" and not re.search(r"R-[A-Z]+-\d{3}", fields.get("Rule", "")):
            errors.append("%s: SUPERSEDED rule must name its replacement" % rid)
        rules[rid] = st

# every id referenced anywhere must exist
pat = re.compile(r"R-(?:LIC|FAC|REQ|SQL)-\d{3}")
for p in root.rglob("*"):
    if p.suffix in {".md", ".sql", ".py"} and ".git" not in p.parts and p.name != "lint_brain.py":
        for rid in set(pat.findall(p.read_text())):
            if rid not in rules:
                errors.append("%s references unknown rule %s" % (p.relative_to(root), rid))

# every ASSUMPTION must be listed as open
oq = (root / "OPEN_QUESTIONS.md").read_text()
for rid, st in rules.items():
    if st == "ASSUMPTION" and not re.search(r"- \[ \] %s:" % rid, oq):
        errors.append("%s is ASSUMPTION but has no open question" % rid)
# open questions must point at rules that are still assumptions
for rid in re.findall(r"(?m)^- \[ \] (R-[A-Z]+-\d{3}):", oq):
    if rules.get(rid) != "ASSUMPTION":
        errors.append("open question %s but rule is %s" % (rid, rules.get(rid)))

# every table page referenced in rules/queries should exist
for t in ["T_DA_CX_LICENSE_MASTER", "T_DA_CX_CURR_FACILITY_INFO"]:
    if not (root / "tables" / (t + ".md")).exists():
        errors.append("missing table page " + t)

if errors:
    print("\n".join("ERROR: " + e for e in errors))
    sys.exit(1)
print("brain OK: %d rules (%s)" % (len(rules), ", ".join(
    "%s=%d" % (s, list(rules.values()).count(s)) for s in sorted(STATUSES))))
