#!/usr/bin/env bash
# POL08 safe-output max: every safe output sets an integer `max`.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
for f in $(targets "$@"); do
  for o in $(so_outputs "$f"); do
    m=$(q "$f" ".[\"safe-outputs\"].[\"$o\"].max")
    [[ "$m" =~ ^[0-9]+$ ]] || hit "$(rel "$f")" "$(qline "$f" ".[\"safe-outputs\"].[\"$o\"]")" POL08 "safe output '$o' has no integer max"
  done
done
pol_done
