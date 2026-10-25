#!/usr/bin/env bash
# POL04 no secrets in files: gitleaks (default rules) plus a GitHub token pattern grep.
# Repo mode scans the tree with .gitleaks.toml, which allowlists only the POL04/POL20/POL26 bad fixtures.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
command -v gitleaks >/dev/null 2>&1 || { echo "policies/checks/POL04.sh:1 VERIFY missing: gitleaks"; exit 1; }
PAT='gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}'
report=$(mktemp); trap 'rm -f "$report"' EXIT
declare -A seen

scan() { # PATH [gitleaks args...]
  local p=$1; shift
  gitleaks dir "$p" "$@" --no-banner --redact --exit-code 0 -f json -r "$report" >/dev/null 2>&1 || { hit "$(rel "$p")" 1 POL04 "gitleaks failed to run"; return; }
  while IFS=$'\t' read -r file line rule; do
    [ -z "$file" ] && continue
    file=$(rel "$file"); seen["$file:$line"]=1; hit "$file" "$line" POL04 "gitleaks: $rule"
  done < <(jq -r '.[]? | [.File, .StartLine, .RuleID] | @tsv' "$report")
}

grep_pat() { # FILE
  local n; while IFS=: read -r n _; do
    [ -n "${seen["$(rel "$1"):$n"]:-}" ] || hit "$(rel "$1")" "$n" POL04 "GitHub token pattern"
  done < <(grep -nE -- "$PAT" "$1" 2>/dev/null)
}

if repo_mode "$@"; then
  scan "$POL_ROOT" --config "$POL_ROOT/.gitleaks.toml"
  while IFS= read -r f; do
    case "$f" in test/fixtures/bad/POL04.md|test/fixtures/bad/POL20.md|test/fixtures/bad/POL26/*) continue ;; esac
    [ -f "$POL_ROOT/$f" ] && grep_pat "$POL_ROOT/$f"
  done < <(git -C "$POL_ROOT" ls-files)
else
  for a in "$@"; do
    scan "$a"
    if [ -d "$a" ]; then while IFS= read -r f; do grep_pat "$f"; done < <(find "$a" -type f); else grep_pat "$a"; fi
  done
fi
pol_done
