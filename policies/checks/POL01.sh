#!/usr/bin/env bash
# POL01 pinned versions only: remote imports/skills @<40-hex> or @vX.Y.Z, plugins @vX.Y.Z only (C12 v1.1),
# agentPacks paths on the policies/POL01.yml allowlist, actions by full SHA (yml roots: policies/POL01.yml yml_roots).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"

SHA='@[0-9a-f]{40}$'; TAG='@v[0-9]+\.[0-9]+\.[0-9]+$'
mapfile -t ALLOW < <(polcfg POL01 '.agentpacks_allowlist[]')

is_remote() { case "$1" in .*|/*|shared/*) return 1 ;; esac; [[ "$1" == *@* || "$1" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/.+ ]]; }

allowed_path() { # agentPacks path (no owner/repo, no ref) matches an allowlist glob
  local p=$1 g
  # shellcheck disable=SC2053 # g is a glob on purpose
  for g in "${ALLOW[@]}"; do [[ "$p" == $g ]] && return 0; done; return 1
}

check_ref() { # FILE KIND REF
  local f=$1 kind=$2 ref=$3 r; r=$(rel "$f")
  is_remote "$ref" || return 0
  if [ "$kind" = plugins ]; then
    [[ "$ref" =~ $TAG ]] || hit "$r" "$(fline "$f" "$ref")" POL01 "plugins pin must be a vX.Y.Z tag (C12 v1.1): $ref"
  elif ! [[ "$ref" =~ $SHA || "$ref" =~ $TAG ]]; then
    hit "$r" "$(fline "$f" "$ref")" POL01 "$kind ref not pinned to a 40-hex SHA or vX.Y.Z tag: $ref"
  fi
  if [[ "$ref" == svennijhuis/agentPacks/* ]]; then
    local p=${ref#svennijhuis/agentPacks/}; p=${p%@*}
    allowed_path "$p" || hit "$r" "$(fline "$f" "$ref")" POL01 "agentPacks path not on policies/POL01.yml agentpacks_allowlist: $p"
  fi
}

uses_hit() { # FILE USES
  case "$2" in ""|./*|docker://*) return 0 ;; esac
  [[ "$2" =~ $SHA ]] || hit "$(rel "$1")" "$(fline "$1" "$2")" POL01 "action not pinned to a full SHA: $2"
}

yml_walk() { # FILE: whole-file yq walk for *.yml and *.yaml (md keeps q()), a parse error is a hit
  local f=$1 out l u
  if ! out=$(yq '.. | select(tag == "!!map" and has("uses")) | .uses' "$f" 2>/dev/null); then
    l=$(yq '.' "$f" 2>&1 >/dev/null | grep -oE 'line [0-9]+' | head -1 | grep -oE '[0-9]+')
    hit "$(rel "$f")" "${l:-1}" POL01 "parse error"; return
  fi
  while IFS= read -r u; do uses_hit "$f" "$u"; done <<<"$out"
}

for f in $(targets "$@"); do
  case "$f" in *.yml|*.yaml) yml_walk "$f"; continue ;; esac
  for kind in imports skills plugins; do
    while IFS= read -r ref; do [ -n "$ref" ] && check_ref "$f" "$kind" "$ref"; done \
      < <(q "$f" ".${kind}[]? | select(tag == \"!!str\") , (.${kind}[]? | select(tag == \"!!map\") | .uses // .path)")
  done
  while IFS= read -r u; do uses_hit "$f" "$u"; done < <(q "$f" 'del(.imports) | .. | select(tag == "!!map" and has("uses")) | .uses')
done

ROOTS=('.github/workflows/*.yml') # always on; policies/POL01.yml yml_roots can only add roots; *.yml globs also walk *.yaml

add_yml_roots() { # a missing, empty, non-list or unreadable yml_roots is a hit, never fewer roots
  local c="$POL_ROOT/policies/POL01.yml" l t
  l=$(fline "$c" 'yml_roots:')
  if ! t=$(yq '.yml_roots | tag' "$c" 2>/dev/null); then hit policies/POL01.yml 1 POL01 "yml_roots unreadable (yq error)"; return; fi
  [ "$t" = '!!seq' ] || { hit policies/POL01.yml "$l" POL01 "yml_roots missing or not a list"; return; }
  [ "$(yq '.yml_roots | length' "$c")" -gt 0 ] || { hit policies/POL01.yml "$l" POL01 "yml_roots empty"; return; }
  [ "$(yq '[.yml_roots[] | select(tag != "!!str" or . == "")] | length' "$c")" -eq 0 ] \
    || { hit policies/POL01.yml "$l" POL01 "yml_roots entry is not a glob string"; return; }
  mapfile -t -O "${#ROOTS[@]}" ROOTS < <(yq '.yml_roots[]' "$c")
}

if repo_mode "$@"; then
  add_yml_roots
  declare -A SEEN=()
  for g in "${ROOTS[@]}"; do
    gy=$g; case "$g" in *.yml) gy=${g%.yml}.yaml ;; esac
    for y in "$POL_ROOT"/$g "$POL_ROOT"/$gy; do
      [ -e "$y" ] || continue; case "$y" in *.lock.yml|*.lock.yaml) continue ;; esac
      [ -n "${SEEN[$y]:-}" ] && continue; SEEN[$y]=1
      yml_walk "$y"
    done
  done
fi
pol_done
