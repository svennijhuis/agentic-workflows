#!/usr/bin/env bash
# TPL01 + ARC08 PBI template check for scripts/verify.sh. Prints `file:line RULE message` per hit.
#   TPL01  the 5 shared fields (triage, feedback, harness, review-input, kind: skill|script) and
#          `- Source: D<n>|PA<n> ... <url>` are present and not empty or a <placeholder>
#   ARC08  `- Module boundary:` in Technical design is present and filled; `feedback:` is the feedback loop
# Scope (PO fix): only PBIs that are new (A) or edited in place (M) against the base. Moves into done/ (R)
# are bookkeeping and wait for the TPL02 backfill. Base: $TPL_BASE, else merge-base with origin/main.
# Usage: check-pbi-template.sh            diff mode (base...worktree, plus untracked PBI files)
#        check-pbi-template.sh FILE...    check these files (fixtures)
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo "scripts/check-pbi-template.sh:1 VERIFY missing: python3"; exit 1; }
if [ $# -eq 0 ]; then
  base=${TPL_BASE:-$(git merge-base HEAD origin/main 2>/dev/null)}
  [ -n "$base" ] || { echo "scripts/check-pbi-template.sh:1 TPL01 no base (fetch origin/main or set TPL_BASE)"; exit 1; }
  mapfile -t files < <( { git diff --name-status -M "$base" -- docs/pbi | awk '$1 == "A" || $1 == "M" {print $2}'; git ls-files --others --exclude-standard -- docs/pbi; } | sort -u)
  set -- "${files[@]}"
  scope=1
else scope=0; fi
[ $# -eq 0 ] && exit 0
SCOPE=$scope python3 - "$@" <<'PY'
import os, re, sys
skip = {"README.md", "_template.md", "gist-review.md", "feature-matrix.md", "workflow-ratings.md", "vision.md"}
def is_pbi(f):
    b = os.path.basename(f)
    return f.startswith("docs/pbi/") and f.endswith(".md") and "/decisions/" not in f and b not in skip and not b.startswith("00-") and f.count("/") >= 3
hits = 0
_print = print
def print(m):
    global hits; hits += 1; _print(m)
FIELDS = [("triage", r"\S"), ("feedback", r"\S"), ("harness", r"\S"), ("review-input", r"\S"), ("kind", r"(skill|script)\b")]
for f in sys.argv[1:]:
    if os.environ["SCOPE"] == "1" and not is_pbi(f): continue
    if not os.path.isfile(f): continue
    lines = open(f, encoding="utf-8").read().split("\n")
    def find(key):
        for i, l in enumerate(lines, 1):
            m = re.match(r"^- " + re.escape(key) + r":(.*)$", l)
            if m: return i, m.group(1).strip()
        return None, None
    for key, pat in FIELDS:
        i, v = find(key)
        if i is None: print(f"{f}:1 TPL01 missing field: {key}")
        elif not v or v.startswith("<") or not re.match(pat, v): print(f"{f}:{i} TPL01 empty or invalid field: {key}" + (" (skill|script)" if key == "kind" else ""))
    i, v = find("Source")
    if i is None: print(f"{f}:1 TPL01 missing field: Source")
    elif not re.search(r"\b(D\d+|PA\d+)\b", v or "") or not re.search(r"https?://\S+", v or ""): print(f"{f}:{i} TPL01 Source needs D<n> or PA<n> plus a URL")
    i, v = find("Module boundary")
    if i is None: print(f"{f}:1 ARC08 missing field: Module boundary")
    elif not v or v.startswith("<"): print(f"{f}:{i} ARC08 empty field: Module boundary")
sys.exit(1 if hits else 0)
PY
