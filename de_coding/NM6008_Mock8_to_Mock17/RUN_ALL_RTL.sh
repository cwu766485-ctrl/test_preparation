#!/usr/bin/env bash
set -euo pipefail
if ! command -v iverilog >/dev/null 2>&1; then
  echo 'Icarus Verilog not installed. Use your lab VCS and per-test README.' >&2
  exit 2
fi
for d in Mock*; do
  [ -d "$d" ] || continue
  rtl=("$d"/rtl/*.v)
  tb=("$d"/tb/tb_*.sv)
  mkdir -p "$d/build"
  # exclude _gate.sv wrapper; select exact first base TB
  base_tb=""
  for p in "${tb[@]}"; do [[ "$p" == *_gate.sv ]] || base_tb="$p"; done
  echo "=== $d ==="
  iverilog -g2012 -s "$(basename "$base_tb" .sv)" -o "$d/build/simv" "$base_tb" "${rtl[@]}"
  (cd "$d/build" && ./simv)
done
