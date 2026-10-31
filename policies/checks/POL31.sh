#!/usr/bin/env bash
# POL31 no skills: in a shared fragment (C12b). gh-aw reads skills: only from the main workflow and
#   silently drops it from an imported fragment, so a skills: key under workflows/shared/ installs nothing.
#   No args: scan workflows/shared/ of the repo. Path arg: scan every *.md under any workflows/shared/
#   found below that root (recursive, so nested bad cases are seen from the parent); a file arg is checked
#   only when it sits under a workflows/shared/ folder. README.md files are docs, not fragments.
#   A file that starts with --- is read as frontmatter. A skills key is one hit. Frontmatter that cannot be
#   read, has no closing ---, does not parse or is not a map is one parse error hit (fail closed, never a skip).
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"

shared_files() { # ROOT: *.md under every workflows/shared/ below ROOT (README.md excluded)
  local a=${1%/}
  if [ -f "$a" ]; then
    case "$(realpath -m "$a")" in */workflows/shared/*) [ "$(basename "$a")" = README.md ] || echo "$a" ;; esac
    return
  fi
  find "$a" -type f -name '*.md' ! -name 'README.md' -path '*/workflows/shared/*' | sort
}

check_file() { # FILE
  local f=$1 r first close kind l; r=$(rel "$f")
  if ! first=$(head -n 1 "$f" 2>/dev/null); then hit "$r" 1 POL31 "parse error"; return; fi
  [ "$first" = "---" ] || return 0
  close=$(awk 'NR > 1 && $0 == "---" {print NR; exit}' "$f")
  if [ -z "$close" ]; then hit "$r" 1 POL31 "parse error"; return; fi
  if ! kind=$(fm "$f" | yq -p yaml 'tag' 2>/dev/null); then hit "$r" 1 POL31 "parse error"; return; fi
  case "$kind" in
    '!!map') ;;
    '!!null'|'') return 0 ;;
    *) hit "$r" 1 POL31 "parse error"; return ;;
  esac
  if [ "$(fm "$f" | yq -p yaml 'has("skills")' 2>/dev/null)" = "true" ]; then
    l=$(grep -nE -m1 '^skills[[:space:]]*:' "$f" | cut -d: -f1); hit "$r" "${l:-1}" POL31 "skills in shared fragment is silently dropped"
  fi
}

if repo_mode "$@"; then set -- "$POL_ROOT/workflows/shared"; fi
for a in "$@"; do
  while IFS= read -r f; do [ -n "$f" ] && check_file "$f"; done < <(shared_files "$a")
done
pol_done
