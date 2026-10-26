#!/usr/bin/env bash
# POL23 no tautological checks.
# Repo mode: every policies/checks/POLnn.sh must exit exactly 1 on its bad fixture and 0 on its good fixture.
#   Any other status (2 included) on a bad case is a hit (VF01).
#   The fixture is the folder bad/POLnn/ (or good/POLnn/) when it exists, else POLnn.md.
#   Inside a bad folder, every immediate child (file or directory) is a case and must exit 1 on its own;
#   a directory case runs as one unit. A X.lock.yml or X.card.yml beside X.md is part of the X.md case.
#   Extra cases: every bad/POLnn-* (file or directory) must exit 1 and every good/POLnn-* must exit 0.
#   Every check passes good/gate-minimal.md; POL23 itself must fail on bad/POL23.md.
# File mode: a file holding a ```sh check block and a ```md sample block is a candidate check; it fails
#   POL23 when the check exits 0 on its own bad sample. Any other file is a good workflow that every
#   POL01-POL22 check must pass.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
C="$POL_ROOT/policies/checks"; FX="$POL_ROOT/test/fixtures"

block() { awk -v t="$2" '$0 == "```" t {on=1; next} on && $0 == "```" {exit} on {print}' "$1"; }

file_mode() { # FILE
  local f=$1 r; r=$(rel "$f")
  if grep -qx '```sh' "$f"; then
    local d; d=$(mktemp -d)
    block "$f" sh > "$d/check.sh"; block "$f" md > "$d/sample.md"
    if (cd "$d" && bash ./check.sh ./sample.md >/dev/null 2>&1); then
      hit "$r" "$(fline "$f" '```sh')" POL23 "check passes on its own bad sample (tautological)"
    fi
    rm -rf "$d"; return
  fi
  local c id
  for c in "$C"/POL[0-9][0-9].sh; do
    id=$(basename "$c" .sh); [ "$id" = POL23 ] && continue
    bash "$c" "$f" >/dev/null 2>&1 || hit "$r" 1 POL23 "good fixture fails $id"
  done
}

companion() { # PATH: true for X.lock.yml or X.card.yml with X.md beside it
  local b d; b=$(basename "$1"); d=$(dirname "$1")
  case "$b" in
    *.lock.yml) [ -e "$d/${b%.lock.yml}.md" ] ;;
    *.card.yml) [ -e "$d/${b%.card.yml}.md" ] ;;
    *) return 1 ;;
  esac
}

expect() { # CHECK ID WANT PATH WHAT: run CHECK on PATH, hit unless it exits WANT
  local c=$1 id=$2 want=$3 x=${4%/} what=$5 rc
  bash "$c" "$x" >/dev/null 2>&1; rc=$?
  [ "$rc" -eq "$want" ] && return 0
  if [ "$want" -eq 1 ] && [ "$rc" -eq 0 ]; then hit "$(rel "$x")" 1 POL23 "$id passes $what $(basename "$x") (tautological)"
  elif [ "$want" -eq 1 ]; then hit "$(rel "$x")" 1 POL23 "$id exits $rc on $what $(basename "$x"), must be 1"
  else hit "$(rel "$x")" 1 POL23 "$id fails $what $(basename "$x") (exit $rc)"; fi
}

if repo_mode "$@"; then
  for c in "$C"/POL[0-9][0-9].sh; do
    id=$(basename "$c" .sh)
    bad="$FX/bad/$id.md"; [ -d "$FX/bad/$id" ] && bad="$FX/bad/$id/"
    good="$FX/good/$id.md"; [ -d "$FX/good/$id" ] && good="$FX/good/$id/"; [ "$id" = POL23 ] && good="$FX/good/gate-minimal.md"
    if [ ! -e "$bad" ]; then hit "$(rel "$c")" 1 POL23 "no bad fixture $(rel "$bad")"
    else expect "$c" "$id" 1 "$bad" "its bad fixture"; fi
    if [ -d "$bad" ]; then
      for x in "$bad"*; do
        [ -e "$x" ] || continue; companion "$x" && continue
        expect "$c" "$id" 1 "$x" "bad case"
      done
    fi
    if [ ! -e "$good" ]; then hit "$(rel "$c")" 1 POL23 "no good fixture $(rel "$good")"
    else expect "$c" "$id" 0 "$good" "its good fixture"; fi
    for x in "$FX/bad/$id"-*; do
      [ -e "$x" ] || continue; companion "$x" && continue
      expect "$c" "$id" 1 "$x" "bad case"
    done
    for x in "$FX/good/$id"-*; do
      [ -e "$x" ] || continue; companion "$x" && continue
      expect "$c" "$id" 0 "$x" "good case"
    done
  done
  file_mode "$FX/good/gate-minimal.md"
else
  for f in $(targets "$@"); do file_mode "$f"; done
fi
pol_done
