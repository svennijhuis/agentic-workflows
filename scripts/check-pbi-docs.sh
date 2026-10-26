#!/usr/bin/env bash
# PBI and doc hygiene for scripts/verify.sh. Prints `file:line RULE message` per hit.
# Exit 0 only with empty output, 1 on any finding, 2 when it cannot run (VF01).
#   A1    every PBI file has `- proof: <cmd>` and `- door: two-way|one-way`; one-way also has a one-way gate line
#   DONE  every PBI in docs/pbi/done/ has `- Status: done` and `- PR: #<n>`
#   LINK  every relative markdown link in tracked or untracked (not ignored) .md files resolves (fixtures excluded)
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo "scripts/check-pbi-docs.sh:1 VERIFY needs-human missing: python3"; exit 2; }
git ls-files -z --cached --others --exclude-standard '*.md' | python3 -c '
import os, re, sys
hits = 0
_print = print
def print(m):
    global hits; hits += 1; _print(m)
files = [f for f in sys.stdin.read().split("\0") if f and os.path.exists(f) and not f.startswith("test/fixtures/")]
skip = {"README.md", "_template.md", "gist-review.md", "feature-matrix.md", "workflow-ratings.md", "vision.md"}
for f in files:
    if not f.startswith("docs/pbi/") or "/decisions/" in f or os.path.basename(f) in skip or os.path.basename(f).startswith("00-") or f.count("/") < 3:
        continue
    t = open(f, encoding="utf-8").read()
    if not re.search(r"^- proof: \S", t, re.M): print(f"{f}:1 A1 missing proof: field")
    m = re.search(r"^- door: (two-way|one-way)", t, re.M)
    if not m: print(f"{f}:1 A1 missing door: two-way|one-way field")
    elif m.group(1) == "one-way" and not re.search(r"^- one-way gate: .*[Ss]ven.*[Rr]ollback", t, re.M): print(f"{f}:1 A1 one-way PBI without one-way gate line (Sven yes + rollback)")
    if f.startswith("docs/pbi/done/") and f != "docs/pbi/done/.gitkeep":
        if not re.search(r"^- Status: done$", t, re.M): print(f"{f}:1 DONE Status is not done")
        if not re.search(r"^- PR: #\d+$", t, re.M): print(f"{f}:1 DONE missing PR: #<n>")
for f in files:
    lines = open(f, encoding="utf-8").read().split("\n"); fence = False
    for i, l in enumerate(lines, 1):
        if l.lstrip().startswith("```"): fence = not fence; continue
        if fence: continue
        for u in re.findall(r"\]\(([^)\s]+)\)", l):
            if re.match(r"^(https?:|mailto:|#)", u): continue
            p = u.split("#")[0]
            if p and not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(f), p))):
                print(f"{f}:{i} LINK broken relative link {u}")
sys.exit(1 if hits else 0)
'
