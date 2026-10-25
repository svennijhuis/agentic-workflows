#!/usr/bin/env bash
# POL07 tool, MCP and bash allowlists: no bash wildcard or bash: true, no github toolset `all`,
# every mcp-servers entry names its allowed tools without a wildcard.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
for f in $(targets "$@"); do
  r=$(rel "$f")
  bt=$(q "$f" '.tools.bash | tag')
  if [ "$bt" = "!!bool" ] || [ "$bt" = "!!null" ] && [ "$(q "$f" '.tools | has("bash")')" = "true" ]; then
    hit "$r" "$(qline "$f" .tools.bash)" POL07 "tools.bash must be an explicit command list"
  fi
  while IFS= read -r c; do
    case "$c" in '*'|':*'|'*:*') hit "$r" "$(qline "$f" .tools.bash)" POL07 "bash wildcard: '$c'" ;; esac
  done < <(q "$f" '.tools.bash[]?')
  for t in $(q "$f" '.tools.github.toolsets[]?'); do
    [ "$t" = all ] && hit "$r" "$(qline "$f" .tools.github.toolsets)" POL07 "github toolset 'all' is not an allowlist"
  done
  for s in $(q "$f" '.["mcp-servers"] | keys | .[]'); do
    a=$(q "$f" ".[\"mcp-servers\"].[\"$s\"].allowed | tag")
    if [ "$a" != "!!seq" ]; then hit "$r" "$(qline "$f" ".[\"mcp-servers\"].[\"$s\"]")" POL07 "mcp server '$s' has no allowed: list"
    elif [ "$(q "$f" ".[\"mcp-servers\"].[\"$s\"].allowed | contains([\"*\"])")" = "true" ]; then hit "$r" "$(qline "$f" ".[\"mcp-servers\"].[\"$s\"].allowed")" POL07 "mcp server '$s' allows '*'"; fi
  done
done
pol_done
