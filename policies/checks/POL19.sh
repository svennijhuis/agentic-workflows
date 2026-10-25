#!/usr/bin/env bash
# POL19 no force push: automation, scripts and operator docs never rewrite remote history (force flag, lease or plus refspec);
# the proposed ruleset export keeps non_fast_forward (Sven applies the ruleset, one-way).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
RX='push([[:space:]]+[^[:space:]]+)*[[:space:]]+(-f|--force|--force-with-lease)([[:space:]=]|$)|push([[:space:]]+[^[:space:]]+)*[[:space:]]+\+[A-Za-z0-9_/]'
scan() { local n; while IFS=: read -r n _; do hit "$(rel "$1")" "$n" POL19 "history rewriting push (force flag, lease or plus refspec)"; done < <(grep -nE -- "$RX" "$1" 2>/dev/null); }
if repo_mode "$@"; then
  while IFS= read -r f; do
    case "$f" in test/fixtures/bad/*|docs/pbi/*) continue ;; esac
    case "$f" in .github/*|scripts/*|policies/*|workflows/*|docs/how-to/*|CONTRIBUTING.md|AGENTS.md|README.md) scan "$POL_ROOT/$f" ;; esac
  done < <(git -C "$POL_ROOT" ls-files)
  rs="$POL_ROOT/$(polcfg POL19 '.ruleset')"
  if [ ! -f "$rs" ] || [ "$(jq '[.rules[]? | select(.type == "non_fast_forward")] | length' "$rs")" = 0 ]; then
    hit "$(rel "$rs")" 1 POL19 "ruleset export missing a non_fast_forward rule"
  fi
else
  for a in "$@"; do if [ -d "$a" ]; then while IFS= read -r f; do scan "$f"; done < <(find "$a" -type f); else scan "$a"; fi; done
fi
pol_done
