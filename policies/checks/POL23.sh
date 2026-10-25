#!/usr/bin/env bash
# POL23 no tautological checks.
# Repo mode: every policies/checks/POLnn.sh must exit 1 on its bad fixture and 0 on its good fixture.
#   The fixture is the folder bad/POLnn/ (or good/POLnn/) when it exists, else POLnn.md.
#   Inside a bad folder, every top-level *.md case must also exit 1 on its own (one case, one reason).
#   Extra cases: every bad/POLnn-*.md|yml must exit 1 and every good/POLnn-*.md|yml must exit 0.
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

if repo_mode "$@"; then
  for c in "$C"/POL[0-9][0-9].sh; do
    id=$(basename "$c" .sh)
    bad="$FX/bad/$id.md"; [ -d "$FX/bad/$id" ] && bad="$FX/bad/$id/"
    good="$FX/good/$id.md"; [ -d "$FX/good/$id" ] && good="$FX/good/$id/"; [ "$id" = POL23 ] && good="$FX/good/gate-minimal.md"
    if [ ! -e "$bad" ]; then hit "$(rel "$c")" 1 POL23 "no bad fixture $(rel "$bad")"
    elif bash "$c" "$bad" >/dev/null 2>&1; then hit "$(rel "$bad")" 1 POL23 "$id passes its bad fixture (tautological)"; fi
    if [ -d "$bad" ]; then
      for x in "$bad"*.md; do
        [ -e "$x" ] || continue
        bash "$c" "$x" >/dev/null 2>&1 && hit "$(rel "$x")" 1 POL23 "$id passes bad case $(basename "$x") (tautological)"
      done
    fi
    if [ ! -e "$good" ]; then hit "$(rel "$c")" 1 POL23 "no good fixture $(rel "$good")"
    elif ! bash "$c" "$good" >/dev/null 2>&1; then hit "$(rel "$good")" 1 POL23 "$id fails its good fixture"; fi
    for x in "$FX/bad/$id"-*.md "$FX/bad/$id"-*.yml; do
      [ -e "$x" ] || continue
      bash "$c" "$x" >/dev/null 2>&1 && hit "$(rel "$x")" 1 POL23 "$id passes bad case $(basename "$x") (tautological)"
    done
    for x in "$FX/good/$id"-*.md "$FX/good/$id"-*.yml; do
      [ -e "$x" ] || continue
      bash "$c" "$x" >/dev/null 2>&1 || hit "$(rel "$x")" 1 POL23 "$id fails good case $(basename "$x")"
    done
  done
  file_mode "$FX/good/gate-minimal.md"
else
  for f in $(targets "$@"); do file_mode "$f"; done
fi
pol_done
