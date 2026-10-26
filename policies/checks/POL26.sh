#!/usr/bin/env bash
# POL26 run logs gitignored and scanned (PA2, PA3).
#   Root = the repo (no args) or a fixture folder (its ignore file is named `gitignore`, so it stays inert).
#   1. every sample path in policies/POL26.yml is ignored by the root ignore file
#   2. repo mode: no tracked file sits under a log dir (fixtures excluded)
#   3. gitleaks runs over every log dir that exists under the root
#   A plain file argument (a workflow .md) has no logs: nothing to check.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
command -v gitleaks >/dev/null 2>&1 || { echo "policies/checks/POL26.sh:1 VERIFY needs-human missing: gitleaks"; exit 2; }
report=$(mktemp); tmp=$(mktemp -d); trap 'rm -rf "$report" "$tmp"' EXIT

check_root() { # ROOT IGNOREFILE
  local root=$1 ign=$2 s d n=0
  git -C "$tmp" init -q 2>/dev/null; cp "$ign" "$tmp/.gitignore" 2>/dev/null || : > "$tmp/.gitignore"
  while IFS= read -r s; do
    n=$((n + 1))
    git -C "$tmp" check-ignore -q --no-index "$s" || hit "$(rel "$ign")" 1 POL26 "run log path $s is not ignored"
  done < <(polcfg POL26 '.samples[]')
  while IFS= read -r d; do
    [ -d "$root/$d" ] || continue
    if ! gitleaks dir "$root/$d" --no-banner --redact --exit-code 0 -f json -r "$report" >/dev/null 2>&1; then
      hit "$(rel "$root/$d")" 1 POL26 "gitleaks failed to run on log dir"; continue
    fi
    while IFS=$'\t' read -r file line rule; do
      [ -n "$file" ] && hit "$(rel "$file")" "$line" POL26 "gitleaks on run log: $rule"
    done < <(jq -r '.[]? | [.File, .StartLine, .RuleID] | @tsv' "$report")
  done < <(polcfg POL26 '.log_dirs[]')
}

if repo_mode "$@"; then
  check_root "$POL_ROOT" "$POL_ROOT/.gitignore"
  while IFS= read -r d; do
    while IFS= read -r f; do hit "$f" 1 POL26 "run log is tracked (git rm --cached it)"; done < <(git -C "$POL_ROOT" ls-files -- "$d" | grep -v '^test/fixtures/')
  done < <(polcfg POL26 '.log_dirs[]')
else
  for a in "$@"; do [ -d "$a" ] && check_root "${a%/}" "${a%/}/gitignore"; done
fi
pol_done
