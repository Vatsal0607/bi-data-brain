"""Concatenate the brain into one markdown file (for pasting into a Claude Project)."""
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parent.parent
parts = ["README.md", "glossary.md", "joins.md", "OPEN_QUESTIONS.md"]
parts += sorted(str(p.relative_to(root)) for p in (root / "tables").glob("*.md"))
parts += sorted(str(p.relative_to(root)) for p in (root / "mappings").glob("*.md"))
parts += sorted(str(p.relative_to(root)) for p in (root / "rules").glob("*.md"))
out = []
for rel in parts:
    out.append("\n\n<!-- %s -->\n\n" % rel + (root / rel).read_text())
dest = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else root / "PROJECT_SNAPSHOT.md"
dest.write_text("# BI Data Brain snapshot\n" + "".join(out))
print("wrote", dest)
