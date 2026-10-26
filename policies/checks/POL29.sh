#!/usr/bin/env bash
# POL29 gate self-test: compile, actionlint, lock drift and the PBI docs check turn red (VF01).
# Args: a case folder (a mini repo holding workflows/, .github/workflows/ or docs/), or a folder of case
#   folders. Any other path is not a POL29 root: no line, exit 0.
# Each case is copied to a temp dir, then git init, git add -A and git commit (fixed test identity),
# then the gate steps of scripts/lib/gate-steps.sh run in it: compile and lock drift when workflows/
# exists, actionlint when .github/workflows/ exists, and scripts/check-pbi-docs.sh (copied to the temp
# repo root) when docs/ exists. Every finding prints as `case/file:line POL29 <finding>`, exit 1.
# check-pbi-docs.sh that prints a finding and exits 0 is a hit too. Exit 2 only when git or the
# compiler cannot run in the temp repo.
# Repo mode: test/fixtures/bad/POL29/ has the four contract cases.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
# shellcheck source=../../scripts/lib/gate-steps.sh
. "$POL_ROOT/scripts/lib/gate-steps.sh"
CASES="compile-error actionlint-error lock-drift pbi-docs-finding"
T=""; trap '[ -n "$T" ] && rm -rf "$T"' EXIT

hitl() { echo "$1/${2%% *} POL29 ${2#* }"; HITS=$((HITS + 1)); } # CASE_REL GATE_LINE
human() { echo "$1:1 VERIFY needs-human POL29 $2"; exit 2; } # CASE_REL REASON

is_case() { [ -d "$1/workflows" ] || [ -d "$1/.github/workflows" ] || [ -d "$1/docs" ]; }

step() { # CASE_REL NAME CMD...: run a gate step in the temp repo, map its findings
  local r=$1 name=$2 out rc; shift 2
  out=$("$@" 2>/dev/null); rc=$?
  [ "$rc" -eq 0 ] || [ "$rc" -eq 1 ] || human "$r" "$name exited $rc in the temp repo"
  [ "$rc" -eq 0 ] || [ -n "$out" ] || human "$r" "$name exited 1 with no finding"
  while IFS= read -r l; do [ -n "$l" ] && hitl "$r" "$l"; done <<<"$out"
}

run_case() { # DIR
  local c=$1 r out rc; r=$(rel "$c")
  T=$(mktemp -d) || human "$r" "mktemp failed"
  { cp -a "$c/." "$T/" && ( cd "$T" && git init -q && git add -A && git -c user.name=pol29 -c user.email=pol29@example.invalid commit -qm case ); } >/dev/null 2>&1 \
    || human "$r" "git cannot run in the temp repo"
  pushd "$T" >/dev/null || human "$r" "cannot enter the temp repo"
  if [ -d workflows ]; then
    gh aw version >/dev/null 2>&1 || human "$r" "gh aw cannot run"
    step "$r" compile gate_compile
    step "$r" "lock drift" gate_drift
  fi
  [ -d .github/workflows ] && step "$r" actionlint gate_actionlint
  if [ -d docs ]; then
    { mkdir -p scripts && cp "$POL_ROOT/scripts/check-pbi-docs.sh" scripts/ && git add scripts && git -c user.name=pol29 -c user.email=pol29@example.invalid commit -qm docs-check; } >/dev/null 2>&1 \
      || human "$r" "git cannot commit scripts/check-pbi-docs.sh in the temp repo"
    out=$(bash scripts/check-pbi-docs.sh 2>/dev/null); rc=$?
    [ "$rc" -eq 2 ] && human "$r" "check-pbi-docs.sh exited 2"
    while IFS= read -r l; do [ -n "$l" ] && hitl "$r" "$l"; done <<<"$out"
    [ -n "$out" ] && [ "$rc" -eq 0 ] && hit "$r/scripts/check-pbi-docs.sh" 1 POL29 "check-pbi-docs.sh printed a finding and exited 0"
    [ -z "$out" ] && [ "$rc" -ne 0 ] && hit "$r/scripts/check-pbi-docs.sh" 1 POL29 "check-pbi-docs.sh exited $rc with no finding"
  fi
  popd >/dev/null || exit 2
  rm -rf "$T"; T=""
}

check_arg() { # PATH
  local a=${1%/} x
  [ -d "$a" ] || return 0
  if is_case "$a"; then run_case "$a"; return; fi
  for x in "$a"/*/; do [ -d "$x" ] && is_case "${x%/}" && run_case "${x%/}"; done
}

if repo_mode "$@"; then
  for x in $CASES; do [ -d "$POL_ROOT/test/fixtures/bad/POL29/$x" ] || hit "test/fixtures/bad/POL29/$x" 1 POL29 "gate self-test case missing"; done
  [ -d "$POL_ROOT/test/fixtures/good/POL29" ] || hit test/fixtures/good/POL29 1 POL29 "gate self-test good repo missing"
else
  for a in "$@"; do check_arg "$a"; done
fi
pol_done
