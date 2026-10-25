#!/usr/bin/env bash
# POL12 explicit repos: a custom github-token (cross-repo signal) needs target-repo or allowed-repos;
# every target-repo / allowed-repos / policies/POL01.yml m05_repos entry is owned by the owner in policies/POL12.yml.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
OWNER=$(polcfg POL12 '.owner')

own() { # FILE LINE WHAT REPO
  local o=${4%%/*}
  [ "$4" = "*" ] && return 0
  [ "$o" = "$OWNER" ] || hit "$1" "$2" POL12 "$3 '$4' is not owned by $OWNER"
}

check_yaml() { # FILE (frontmatter via q) 
  local f=$1 r; r=$(rel "$f")
  local tokens; tokens=$(q "$f" '[.["safe-outputs"]["github-token"], (.["safe-outputs"][]? | select(tag == "!!map") | .["github-token"]), .tools.github["github-token"]] | map(select(. != null)) | length')
  local scoped; scoped=$(q "$f" '[(.["safe-outputs"][]? | select(tag == "!!map") | (.["target-repo"], .["allowed-repos"])), .tools.github["allowed-repos"]] | map(select(. != null)) | length')
  if [ "${tokens:-0}" -gt 0 ] && [ "${scoped:-0}" -eq 0 ]; then
    hit "$r" "$(fline "$f" github-token)" POL12 "custom github-token (cross-repo) without target-repo or allowed-repos"
  fi
  local o t
  for o in $(so_outputs "$f"); do
    t=$(q "$f" ".[\"safe-outputs\"].[\"$o\"].[\"target-repo\"]")
    [ -n "$t" ] && own "$r" "$(qline "$f" ".[\"safe-outputs\"].[\"$o\"].[\"target-repo\"]")" "$o target-repo" "$t"
    if [ "$t" = "*" ] && [ "$(q "$f" ".[\"safe-outputs\"].[\"$o\"].[\"allowed-repos\"] | tag")" != "!!seq" ]; then
      hit "$r" "$(qline "$f" ".[\"safe-outputs\"].[\"$o\"]")" POL12 "$o target-repo '*' needs an allowed-repos list"
    fi
    while IFS= read -r t; do [ -n "$t" ] && own "$r" "$(fline "$f" "$t")" "$o allowed-repos" "$t"; done < <(q "$f" ".[\"safe-outputs\"].[\"$o\"].[\"allowed-repos\"][]?")
  done
  while IFS= read -r t; do [ -n "$t" ] && own "$r" "$(fline "$f" "$t")" "tools.github allowed-repos" "$t"; done < <(q "$f" '.tools.github["allowed-repos"] | select(tag == "!!seq") | .[]')
  while IFS= read -r t; do [ -n "$t" ] && own "$r" "$(fline "$f" "$t")" "m05.repos" "$t"; done < <(q "$f" '.m05.repos[]?')
}

for f in $(targets "$@"); do check_yaml "$f"; done
if repo_mode "$@"; then
  # M05 allowlist lives in the one allowlist file, policies/POL01.yml (aw.yml rejects unknown keys).
  while IFS= read -r t; do
    [ -n "$t" ] && own policies/POL01.yml "$(fline "$POL_ROOT/policies/POL01.yml" "$t")" "m05_repos" "$t"
  done < <(yq '.m05_repos[]?' "$POL_ROOT/policies/POL01.yml")
fi
pol_done
