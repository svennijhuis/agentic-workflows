#!/usr/bin/env bash
# Gate steps shared by scripts/verify.sh and policies/checks/POL29.sh (VF01), so the gate and its
# self-test run the same commands. Each step runs in the current directory (a git repo root), prints
# one `file:line RULE message` per finding and returns 0 clean, 1 findings, other non-zero when it
# could not run (the caller turns that into exit 2).
#
# gate_snapshot SRC DEST  copy SRC's working tree (tracked files as on disk, every untracked file that
#                         is not ignored, plus the ignored gh-aw cache .github/aw/actions-lock.json and
#                         .github/aw/imports/) into DEST and commit it, so drift diffs against it
# gate_compile            gh aw compile --dir workflows --strict --actionlint (writes only this tree)
# gate_drift              files under workflows/ that differ from the snapshot commit after compile
# gate_actionlint         actionlint on .github/workflows/*.yml (not *.lock.yml)
# gate_shellcheck         shellcheck on scripts/*.sh scripts/lib/*.sh policies/checks/*.sh

gate_snapshot() {
  local src=$1 dest=$2
  ( set -o pipefail
    ( cd "$src" || exit 2
      git ls-files -z --cached --others --exclude-standard || exit 2
      for f in .github/aw/actions-lock.json .github/aw/imports; do if [ -e "$f" ]; then printf '%s\0' "$f"; fi; done
    ) | while IFS= read -r -d '' f; do if [ -e "$src/$f" ] || [ -L "$src/$f" ]; then printf '%s\0' "$f"; fi; done \
      | (cd "$src" && tar --null -T - -cf -) | (cd "$dest" && tar -xf -)
  ) || return 2
  ( cd "$dest" && git init -q && git add -A && git -c user.name=verify -c user.email=verify@example.invalid commit -qm snapshot --allow-empty ) >/dev/null 2>&1 || return 2
}

gate_compile() {
  local out rc lines
  out=$(gh aw compile --dir workflows --strict --actionlint 2>&1); rc=$?
  if grep -q 'actionlint failed' <<<"$out"; then
    echo "workflows:1 VERIFY needs-human actionlint did not run inside gh aw compile"; return 2
  fi
  lines=$(
    grep -oE 'workflows/[^ :]+\.(md|lock\.yml):[0-9]+(:[0-9]+)?: (error|warning).*' <<<"$out" | sed -E 's#^(workflows/[^:]+):([0-9]+)(:[0-9]+)?: #\1:\2 COMPILE #'
    grep -oE 'workflows/[^ :]+\.md: warning: .*' <<<"$out" | sed -E 's#^(workflows/[^:]+): warning: #\1:1 COMPILE warning: #'
    if grep -q 'Actionlint Summary' <<<"$out" && ! grep -q 'No issues found' <<<"$out"; then
      grep -oE '[^ ]+\.lock\.yml:[0-9]+:[0-9]+: .*' <<<"$out" | sed -E 's#^.*(workflows/[^:]+):([0-9]+):[0-9]+: #\1:\2 ACTIONLINT #' | grep . \
        || echo "workflows:1 ACTIONLINT issues reported by gh aw compile --actionlint"
    fi
  )
  [ -n "$lines" ] && { echo "$lines"; return 1; }
  return "$rc"
}

gate_drift() {
  local d u
  d=$(git diff --name-only -- workflows) || return 2
  u=$(git ls-files --others --exclude-standard -- workflows) || return 2
  printf '%s\n%s\n' "$d" "$u" | sed '/^$/d' | sed -E 's#$#:1 POL17 compile changed this file (run gh aw compile and commit the result)#' | grep . && return 1
  return 0
}

gate_actionlint() {
  local y s rc=0
  for y in .github/workflows/*.yml; do
    [ -e "$y" ] || continue; case "$y" in *.lock.yml) continue ;; esac
    actionlint -no-color -oneline "$y" | sed -E 's#^([^:]+):([0-9]+):[0-9]+: #\1:\2 ACTIONLINT #'
    s=${PIPESTATUS[0]}
    case "$s" in 0) ;; 1) rc=1 ;; *) return "$s" ;; esac
  done
  return "$rc"
}

gate_shellcheck() {
  shellcheck -f gcc -x -P SCRIPTDIR scripts/*.sh scripts/lib/*.sh policies/checks/*.sh 2>&1 | sed -E 's#^([^:]+):([0-9]+):[0-9]+: (.*)#\1:\2 SHELLCHECK \3#'
  return "${PIPESTATUS[0]}"
}
