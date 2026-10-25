#!/usr/bin/env bash
# POL24 agent card (HX02): every workflow has a sibling <name>.card.yml with the required keys.
#   engine and tools match the workflow frontmatter (engine resolved through local imports);
#   when the sibling .lock.yml exists, mcp names equal the lock manifest mcp_servers and every secret
#   name is in the manifest secrets; secrets are NAMES (or none), never a value or an expression.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
RE=$(polcfg POL24 .secret_name)
TRANSPORTS=" $(polcfg POL24 '.transports | join(" ")') "
PATS=$(yq '.patterns | join("|")' "$POL_ROOT/policies/POL20.yml")

engine_of() { # WORKFLOW: frontmatter engine (string or .id), else the first local import that sets one
  local f=$1 e i
  e=$(q "$f" '(.engine | select(tag == "!!map") | .id) // (.engine | select(tag == "!!str"))')
  if [ -z "$e" ]; then
    for i in $(q "$f" '.imports[]? | select(tag == "!!str")'); do
      case "$i" in */*@*) continue ;; esac
      [ -f "$(dirname "$f")/$i" ] || continue
      e=$(q "$(dirname "$f")/$i" '(.engine | select(tag == "!!map") | .id) // (.engine | select(tag == "!!str"))'); [ -n "$e" ] && break
    done
  fi
  echo "$e"
}

for f in $(targets "$@"); do
  is_workflow "$f" || continue
  r=$(rel "$f"); card="${f%.md}.card.yml"; rc=$(rel "$card"); name=$(basename "$f" .md)
  if [ ! -f "$card" ]; then hit "$r" 1 POL24 "no agent card $rc"; continue; fi
  if ! yq -e 'tag == "!!map"' "$card" >/dev/null 2>&1; then hit "$rc" 1 POL24 "agent card is not a YAML map"; continue; fi
  for k in $(polcfg POL24 '.required[]'); do
    [ "$(yq "has(\"$k\") and .$k != null and .$k != \"\"" "$card")" = true ] || hit "$rc" 1 POL24 "missing or empty field: $k"
  done
  [ "$(yq '.workflow' "$card")" = "$name" ] || hit "$rc" "$(gline "$card" '^workflow:')" POL24 "workflow is '$(yq '.workflow' "$card")', file is $name"
  want=$(engine_of "$f"); have=$(yq '.engine // ""' "$card")
  [ "$want" = "$have" ] || hit "$rc" "$(gline "$card" '^engine:')" POL24 "engine '$have' differs from frontmatter '${want:-unset}'"
  want=$(q "$f" '.tools | keys | sort | join(",")'); have=$(yq '.tools // [] | sort | join(",")' "$card")
  [ "$want" = "$have" ] || hit "$rc" "$(gline "$card" '^tools:')" POL24 "tools [$have] differ from frontmatter [$want]"
  # secret names: engine_secret plus every mcp row secret
  while IFS=$'\t' read -r line s; do
    [ -z "$s" ] && continue
    [ "$s" = none ] && continue
    [[ "$s" =~ $RE ]] || hit "$rc" "$line" POL24 "secret must be a NAME (A-Z, 0-9, _) or none, not a value"
  done < <(yq -r '[(.engine_secret | [line, .]), (.mcp[]?.secret | [line, .])] | .[] | @tsv' "$card")
  while IFS=$'\t' read -r line t n; do
    case "$TRANSPORTS" in *" $t "*) ;; *) hit "$rc" "$line" POL24 "mcp '$n' transport '$t' is not one of:$TRANSPORTS" ;; esac
  done < <(yq -r '.mcp[]? | [line, (.transport // ""), (.name // "")] | @tsv' "$card")
  n=$(grep -nE -m1 -- '\$\{\{|'"$PATS" "$card" | cut -d: -f1)
  [ -z "$n" ] || hit "$rc" "$n" POL24 "secret value or expression in agent card (names only)"
  lock="${f%.md}.lock.yml"
  if [ -f "$lock" ]; then
    man=$(sed -n '1,5s/^# gh-aw-manifest: //p' "$lock")
    if [ -n "$man" ]; then
      want=$(jq -r '[.mcp_servers[]?.name] | sort | join(",")' <<<"$man"); have=$(yq '[.mcp[]?.name] | sort | join(",")' "$card")
      [ "$want" = "$have" ] || hit "$rc" "$(gline "$card" '^mcp:')" POL24 "mcp [$have] differ from lock manifest [$want]"
      while IFS=$'\t' read -r line s; do
        { [ -z "$s" ] || [ "$s" = none ]; } && continue
        jq -e --arg s "$s" '.secrets | index($s)' <<<"$man" >/dev/null || hit "$rc" "$line" POL24 "secret $s is not in the lock manifest"
      done < <(yq -r '[(.engine_secret | [line, .]), (.mcp[]?.secret | [line, .])] | .[] | @tsv' "$card")
    fi
  fi
done
pol_done
