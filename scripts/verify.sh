#!/usr/bin/env bash
# The one gate (C01, VF01). Local, CI and every agent run the same script. No args, run from anywhere in the repo.
# Output contract (gist A3): one line per failure `file:line RULE message`, section headers start with `# `,
# last line is always `N failures`.
# Exit codes (PA5): 0 ok, 1 failed (a real finding), 2 needs-human (a tool missing or at the wrong version, or a
# producer that could not run). An exit 2 line reads `file:line VERIFY needs-human <reason>`. Nothing is skipped.
set -uo pipefail
command -v git >/dev/null 2>&1 || { echo "scripts/verify.sh:1 VERIFY needs-human missing: git"; echo "1 failures"; exit 2; }
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "scripts/verify.sh:1 VERIFY needs-human not inside a git repo"; echo "1 failures"; exit 2; }
cd "$ROOT" || exit 2
# shellcheck source=lib/gate-steps.sh
. scripts/lib/gate-steps.sh
N=0; OUT=$(mktemp); WT=$(mktemp -d); trap 'rm -rf "$OUT" "$WT"' EXIT
fail() { echo "$1"; N=$((N + 1)); }
stop2() { echo "$N failures"; exit 2; }
human() { fail "$1"; stop2; }
in_wt() { (cd "$WT" && "$@"); }

# produce NAME CMD...: run one producer into a temp file and keep its own exit code (VF01 gap row 16).
#   (a) a `VERIFY needs-human` line, or status 2: print it and exit 2 at once, even with other lines
#   (b) non-zero with no output line: exit 2 at once
#   (c) otherwise every line is a finding and is counted
produce() {
  local name=$1 rc l; shift
  "$@" >"$OUT"; rc=$?
  if grep -q 'VERIFY needs-human' "$OUT"; then
    while IFS= read -r l; do fail "$l"; done < <(grep 'VERIFY needs-human' "$OUT"); stop2
  fi
  grep -q . "$OUT" || [ "$rc" -eq 0 ] || human "scripts/verify.sh:1 VERIFY needs-human $name exited $rc with no finding"
  [ "$rc" -ne 2 ] || human "scripts/verify.sh:1 VERIFY needs-human $name exited 2: $(grep -m1 . "$OUT")"
  while IFS= read -r l; do [ -n "$l" ] && fail "$l"; done <"$OUT"
}

# pol03_roots: only the failed case lines of scripts/test-POL03-roots.sh (its ok lines and tally are not findings)
pol03_roots() { local o rc; o=$(bash scripts/test-POL03-roots.sh 2>&1); rc=$?; grep ' POL03T ' <<<"$o"; [ "$rc" -eq 0 ] || [ "$rc" -eq 1 ] || return 2; return "$rc"; }

# version_of TOOL: X.Y.Z the installed TOOL reports, empty when it cannot say
version_of() {
  case "$1" in
    actionlint) actionlint -version ;;
    gitleaks) gitleaks version ;;
    *) "$1" --version ;;
  esac 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

echo "# tools (pins in .github/aw.json; git, gh and jq are runner-provided)"
for t in git gh jq; do command -v "$t" >/dev/null 2>&1 || fail "scripts/verify.sh:1 VERIFY needs-human missing: $t"; done
[ "$N" -eq 0 ] || stop2
jq -e '(.["gh-aw"] | type == "string") and (.tools | type == "object")' .github/aw.json >/dev/null 2>&1 \
  || human ".github/aw.json:1 VERIFY needs-human cannot read the gh-aw pin and tools: map"
for t in $(jq -r '.tools | keys[]' .github/aw.json); do
  pin=$(jq -r --arg t "$t" '.tools[$t].version' .github/aw.json); line=$(grep -nF -m1 "\"$t\"" .github/aw.json | cut -d: -f1)
  if ! command -v "$t" >/dev/null 2>&1; then fail "scripts/verify.sh:1 VERIFY needs-human missing: $t"; continue; fi
  have=$(version_of "$t")
  [ "$have" = "$pin" ] || fail ".github/aw.json:${line:-1} VERIFY needs-human $t is ${have:-unknown}, pin is $pin (install tools.$t.url)"
done
PIN_AW=$(jq -r '.["gh-aw"]' .github/aw.json)
have_aw=$(gh aw version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
[ "$have_aw" = "$PIN_AW" ] || fail ".github/aw.json:2 VERIFY needs-human gh-aw is ${have_aw:-missing}, pin is $PIN_AW (gh extension install github/gh-aw --pin $PIN_AW)"
[ "$N" -eq 0 ] || stop2

echo "# working copy (compile, actionlint on locks and lock drift run in a temp copy; the real tree is never written)"
gate_snapshot "$ROOT" "$WT" || human "scripts/verify.sh:1 VERIFY needs-human cannot copy the working tree into a temp repo"

echo "# compile (gh aw compile --dir workflows --strict --actionlint)"
produce compile in_wt gate_compile

echo "# lock drift (POL17)"
produce "lock drift" in_wt gate_drift

echo "# actionlint .github/workflows"
produce actionlint gate_actionlint

echo "# shellcheck"
produce shellcheck gate_shellcheck

echo "# smoke auth check (SM04a: each good exits 0, each bad exits exactly 1 with one hit)"
A=test/fixtures/smoke-auth
shopt -s nullglob; G=("$A"/good*.yml); B=("$A"/bad-*.yml); shopt -u nullglob
[ "${#G[@]}" -gt 0 ] || fail "$A:1 SMOKEAUTH no good smoke auth fixture"
[ "${#B[@]}" -gt 0 ] || fail "$A:1 SMOKEAUTH no bad smoke auth fixture"
for g in "${G[@]}"; do bash scripts/check-smoke-auth.sh "$g" >/dev/null || fail "$g:1 SMOKEAUTH good smoke auth fixture fails"; done
for b in "${B[@]}"; do
  h=$(bash scripts/check-smoke-auth.sh "$b"); rc=$?
  { [ "$rc" -eq 1 ] && [ "$(grep -c . <<<"$h")" -eq 1 ]; } || fail "$b:1 SMOKEAUTH bad smoke auth fixture does not exit 1 with exactly one hit (rc $rc)"
done

echo "# SM05b round 1 (each bad exits exactly 1 with one hit)"
sm05b_one_hit() {
  local check=$1 path=$2 h rc
  h=$(bash "$check" "$path"); rc=$?
  { [ "$rc" -eq 1 ] && [ "$(grep -c . <<<"$h")" -eq 1 ]; } \
    || fail "$path:1 SM05B bad case does not exit 1 with exactly one hit (rc $rc)"
}
sm05b_one_hit policies/checks/POL25.sh test/fixtures/bad/POL25-smoke-no-on
sm05b_one_hit policies/checks/POL25.sh test/fixtures/bad/POL25-smoke-rollout-broken-no-on
sm05b_one_hit policies/checks/POL03.sh test/fixtures/bad/POL03-smoke-metadata-after-name
sm05b_one_hit policies/checks/POL25.sh test/fixtures/bad/POL25-smoke-metadata-after-name
sm05b_one_hit policies/checks/POL03.sh test/fixtures/bad/POL03-smoke-date-bool
sm05b_one_hit policies/checks/POL03.sh test/fixtures/bad/POL03-smoke-date-list
sm05b_one_hit policies/checks/POL25.sh test/fixtures/bad/POL25-smoke-date-bool
sm05b_one_hit policies/checks/POL25.sh test/fixtures/bad/POL25-smoke-date-list
sm05b_one_hit policies/checks/POL03.sh test/fixtures/bad/POL03-smoke-trigger-blank

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
  produce "$(basename "$c" .sh)" bash "$c"
done

echo "# POL23 no tautological checks (every check vs its bad and good fixture)"
produce POL23 bash policies/checks/POL23.sh

echo "# POL03 repo-mode cases (scripts/test-POL03-roots.sh: *.yaml, locks, POL_ROLLOUT, promoted)"
produce test-POL03-roots.sh pol03_roots

echo "# PBI docs (gist A1 proof/door fields, links, dashes)"
produce check-pbi-docs.sh bash scripts/check-pbi-docs.sh

echo "# PBI template (TPL01 + ARC08, new or changed PBIs only)"
T=test/fixtures/template
bash scripts/check-pbi-template.sh "$T/good.md" >/dev/null || fail "$T/good.md:1 TPL01 good template fixture fails"
for b in "$T"/bad-*.md; do bash scripts/check-pbi-template.sh "$b" >/dev/null && fail "$b:1 TPL01 bad template fixture passes (tautological)"; done
produce check-pbi-template.sh bash scripts/check-pbi-template.sh

echo "# smoke scenarios (SM01: each good exits 0, each bad exits exactly 1, every smoke/*/scenarios.yml or .yaml)"
S=test/fixtures/smoke
for g in "$S"/good*.yml; do bash scripts/check-smoke.sh "$g" >/dev/null || fail "$g:1 SMOKE good smoke fixture fails"; done
for b in "$S"/bad-*.yml; do bash scripts/check-smoke.sh "$b" >/dev/null; [ $? -eq 1 ] || fail "$b:1 SMOKE bad smoke fixture does not exit 1 (tautological)"; done
for s in smoke/*/scenarios.yml smoke/*/scenarios.yaml; do [ -e "$s" ] && produce check-smoke.sh bash scripts/check-smoke.sh "$s"; done

echo "# PR template (G02a owner, architecture summary, questions for owner)"
P=test/fixtures/pr-body
produce check-pr-body.sh bash scripts/check-pr-body.sh --template .github/pull_request_template.md
bash scripts/check-pr-body.sh "$P/good.md" >/dev/null || fail "$P/good.md:1 G02a good PR body fixture fails"
for b in "$P"/bad-*.md; do bash scripts/check-pr-body.sh "$b" >/dev/null && fail "$b:1 G02a bad PR body fixture passes (tautological)"; done

echo "# smoke setup checklist (SM07a: smoke/SETUP.md and each good exit 0, each bad exits exactly 1 with one hit)"
U=test/fixtures/smoke-setup
produce check-smoke-setup.sh bash scripts/check-smoke-setup.sh smoke/SETUP.md
shopt -s nullglob; UG=("$U"/good*.md); UB=("$U"/bad-*.md); shopt -u nullglob
[ "${#UG[@]}" -gt 0 ] || fail "$U:1 SMOKESETUP no good setup fixtures"
[ "${#UB[@]}" -gt 0 ] || fail "$U:1 SMOKESETUP no bad setup fixtures"
for g in "${UG[@]}"; do bash scripts/check-smoke-setup.sh "$g" >/dev/null || fail "$g:1 SMOKESETUP good setup fixture fails"; done
for b in "${UB[@]}"; do
  [ -f "$b" ] || { fail "$b:1 SMOKESETUP bad setup fixture is not a file"; continue; }
  h=$(bash scripts/check-smoke-setup.sh "$b"); rc=$?
  { [ "$rc" -eq 1 ] && [ "$(grep -c . <<<"$h")" -eq 1 ]; } || fail "$b:1 SMOKESETUP bad setup fixture does not exit 1 with exactly one hit (rc $rc)"
done

echo "$N failures"
[ "$N" -eq 0 ]
