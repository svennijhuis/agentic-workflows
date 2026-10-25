#!/usr/bin/env bash
# POL20 no tokens in markdown: secret-pattern scan on markdown and workflow sources.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
mapfile -t PATS < <(polcfg POL20 '.patterns[]')
scan() { local p n; for p in "${PATS[@]}"; do while IFS=: read -r n _; do hit "$(rel "$1")" "$n" POL20 "secret pattern in markdown"; done < <(grep -nE -- "$p" "$1" 2>/dev/null); done; }
if repo_mode "$@"; then
  while IFS= read -r f; do
    case "$f" in test/fixtures/bad/POL04.md|test/fixtures/bad/POL20.md) continue ;; esac
    scan "$POL_ROOT/$f"
  done < <(git -C "$POL_ROOT" ls-files '*.md')
else
  for f in $(targets "$@"); do scan "$f"; done
fi
pol_done
