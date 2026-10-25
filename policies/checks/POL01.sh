#!/usr/bin/env bash
# POL01 pinned versions only: remote imports/skills @<40-hex> or @vX.Y.Z, plugins @vX.Y.Z only (C12 v1.1),
# agentPacks paths on the policies/POL01.yml allowlist, actions by full SHA.
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

for f in $(targets "$@"); do
  for kind in imports skills plugins; do
    while IFS= read -r ref; do [ -n "$ref" ] && check_ref "$f" "$kind" "$ref"; done \
      < <(q "$f" ".${kind}[]? | select(tag == \"!!str\") , (.${kind}[]? | select(tag == \"!!map\") | .uses // .path)")
  done
  while IFS= read -r u; do
    [ -z "$u" ] && continue
    case "$u" in ./*|docker://*) continue ;; esac
    [[ "$u" =~ $SHA ]] || hit "$(rel "$f")" "$(fline "$f" "$u")" POL01 "action not pinned to a full SHA: $u"
  done < <(q "$f" 'del(.imports) | .. | select(tag == "!!map" and has("uses")) | .uses')
done

if repo_mode "$@"; then
  for y in "$POL_ROOT"/.github/workflows/*.yml; do
    [ -e "$y" ] || continue; case "$y" in *.lock.yml) continue ;; esac
    while IFS= read -r u; do
      [ -z "$u" ] && continue
      [[ "$u" =~ $SHA ]] || hit "$(rel "$y")" "$(fline "$y" "$u")" POL01 "action not pinned to a full SHA: $u"
    done < <(yq '.. | select(tag == "!!map" and has("uses")) | .uses' "$y")
  done
fi
pol_done
