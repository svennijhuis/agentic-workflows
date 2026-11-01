#!/usr/bin/env bash
# on: normalizer for POL25 (md frontmatter and yml alike). `on: push` (string) would make
# `yq '.on | keys'` error and the loop run empty. Here a string becomes [s], a list stays the list, a map becomes its keys, and anything else
# (a yq or parse error, a list item that is not a string, an unknown shape) is an error the caller must
# count as a hit (fail closed).
#
# on_doc FILE       YAML that holds on: (the frontmatter of a .md, the whole file otherwise)
# on_triggers FILE  trigger names, one per line (map form includes setting keys such as roles; callers
#                   filter them). Exit 0 ok, 3 no on: key (not a workflow), 2 parse error or bad shape.
# on_shape FILE     str | seq | map (only after on_triggers returned 0)
# on_line FILE      line of the on: key in FILE, 1 when not found

on_doc() {
  case "$1" in
    *.md) awk 'NR==1 && $0!="---" {exit} NR==1 {next} $0=="---" {exit} {print}' "$1" ;;
    *) cat "$1" ;;
  esac
}

on_shape() { on_doc "$1" | yq -p yaml '.on | tag' 2>/dev/null | sed 's/^!!//'; }

on_triggers() {
  local doc tag out
  doc=$(on_doc "$1") || return 2
  [ -n "$doc" ] || return 3
  tag=$(printf '%s\n' "$doc" | yq -p yaml '.on | tag' 2>/dev/null) || return 2
  case "$tag" in
    '!!null') [ "$(printf '%s\n' "$doc" | yq -p yaml 'has("on")' 2>/dev/null)" = true ] && return 2; return 3 ;;
    '!!str') out=$(printf '%s\n' "$doc" | yq -p yaml '.on' 2>/dev/null) || return 2 ;;
    '!!seq')
      [ "$(printf '%s\n' "$doc" | yq -p yaml '[.on[] | select(tag != "!!str")] | length' 2>/dev/null)" = 0 ] || return 2
      out=$(printf '%s\n' "$doc" | yq -p yaml '.on[]' 2>/dev/null) || return 2 ;;
    '!!map') out=$(printf '%s\n' "$doc" | yq -p yaml '.on | keys | .[]' 2>/dev/null) || return 2 ;;
    *) return 2 ;;
  esac
  [ -n "$out" ] || return 2
  printf '%s\n' "$out"
}

on_line() { local l; l=$(grep -nE -m1 '^"?on"?:' "$1" | cut -d: -f1); echo "${l:-1}"; }
