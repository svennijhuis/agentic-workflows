#!/usr/bin/env bash
# The one gate (C01). Local and CI run the same script. No args, run from anywhere in the repo.
# Output contract (gist A3): one line per failure `file:line RULE message`, section headers start with `# `,
# last line is always `N failures`. Exit 0 only when N is 0. A missing tool is a failure, never a skip.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2
N=0; OUT=$(mktemp); trap 'rm -f "$OUT"' EXIT
fail() { echo "$1"; N=$((N + 1)); }
count() { local l; while IFS= read -r l; do [ -n "$l" ] && fail "$l"; done; }

echo "# tools"
PIN_AW=$(jq -r '.["gh-aw"]' .github/aw.json 2>/dev/null || echo unknown)
for t in git gh jq yq actionlint gitleaks shellcheck; do command -v "$t" >/dev/null 2>&1 || fail "scripts/verify.sh:1 VERIFY missing: $t"; done
have_aw=$(gh aw version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
[ "$have_aw" = "$PIN_AW" ] || fail ".github/aw.json:1 C06 gh-aw is ${have_aw:-missing}, pin is $PIN_AW (gh extension install github/gh-aw --pin $PIN_AW)"
[ "$N" -eq 0 ] || { echo "$N failures"; exit 1; }

echo "# compile (gh aw compile --dir workflows --strict --actionlint)"
gh aw compile --dir workflows --strict --actionlint >"$OUT" 2>&1; rc=$?
before=$N
count < <(grep -oE 'workflows/[^ :]+\.(md|lock\.yml):[0-9]+(:[0-9]+)?: (error|warning).*' "$OUT" | sed -E 's#^(workflows/[^:]+):([0-9]+)(:[0-9]+)?: #\1:\2 COMPILE #')
count < <(grep -oE 'workflows/[^ :]+\.md: warning: .*' "$OUT" | sed -E 's#^(workflows/[^:]+): warning: #\1:1 COMPILE warning: #')
if grep -q 'Actionlint Summary' "$OUT" && ! grep -q 'No issues found' "$OUT"; then
  count < <(grep -oE '[^ ]+\.lock\.yml:[0-9]+:[0-9]+: .*' "$OUT" | sed -E 's#^([^:]+):([0-9]+):[0-9]+: #\1:\2 ACTIONLINT #')
  [ "$N" -gt "$before" ] || fail "workflows:1 ACTIONLINT issues reported by gh aw compile --actionlint"
fi
[ "$rc" -eq 0 ] || [ "$N" -gt "$before" ] || fail "workflows:1 COMPILE gh aw compile exited $rc: $(grep -m1 -iE 'error|failed' "$OUT")"

echo "# lock drift (POL17)"
count < <({ git diff --name-only -- workflows; git ls-files --others --exclude-standard -- workflows; } | sed -E 's#$#:1 POL17 compile changed this file (run gh aw compile and commit the result)#')

echo "# actionlint .github/workflows"
for y in .github/workflows/*.yml; do
  [ -e "$y" ] || continue; case "$y" in *.lock.yml) continue ;; esac
  count < <(actionlint -no-color -oneline "$y" | sed -E 's#^([^:]+):([0-9]+):[0-9]+: #\1:\2 ACTIONLINT #')
done

echo "# shellcheck"
count < <(shellcheck -f gcc -x -P SCRIPTDIR scripts/*.sh policies/checks/*.sh 2>&1 | sed -E 's#^([^:]+):([0-9]+):[0-9]+: (.*)#\1:\2 SHELLCHECK \3#')

echo "# import-schema fixtures (C05)"
for kind in good bad; do
  d=test/fixtures/import-schema/$kind; tmp=$(mktemp -d); cp -r "$d" "$tmp/w"
  if (cd "$tmp" && git init -q && gh aw compile --dir w --strict --no-emit >/dev/null 2>&1); then rc=0; else rc=1; fi
  rm -rf "$tmp"
  [ "$kind" = good ] && [ $rc -ne 0 ] && fail "$d/consumer.md:1 C05 good import-schema input fails to compile"
  [ "$kind" = bad ] && [ $rc -eq 0 ] && fail "$d/consumer.md:1 C05 unknown import-schema input was not rejected"
done

echo "# policies (every POLnn except POL23, repo mode)"
for c in policies/checks/POL[0-9][0-9].sh; do
  [ "$(basename "$c")" = POL23.sh ] && continue
  count < <(bash "$c")
done

echo "# POL23 no tautological checks (every check vs its bad and good fixture)"
count < <(bash policies/checks/POL23.sh)

echo "# PBI docs (gist A1 proof/door fields, links, dashes)"
count < <(bash scripts/check-pbi-docs.sh)

echo "# PBI template (TPL01 + ARC08, new or changed PBIs only)"
T=test/fixtures/template
bash scripts/check-pbi-template.sh "$T/good.md" >/dev/null || fail "$T/good.md:1 TPL01 good template fixture fails"
for b in "$T"/bad-*.md; do bash scripts/check-pbi-template.sh "$b" >/dev/null && fail "$b:1 TPL01 bad template fixture passes (tautological)"; done
count < <(bash scripts/check-pbi-template.sh)

echo "# PR template (G02a owner, architecture summary, questions for owner)"
P=test/fixtures/pr-body
count < <(bash scripts/check-pr-body.sh --template .github/pull_request_template.md)
bash scripts/check-pr-body.sh "$P/good.md" >/dev/null || fail "$P/good.md:1 G02a good PR body fixture fails"
for b in "$P"/bad-*.md; do bash scripts/check-pr-body.sh "$b" >/dev/null && fail "$b:1 G02a bad PR body fixture passes (tautological)"; done

echo "$N failures"
[ "$N" -eq 0 ]
