#!/usr/bin/env bash
set -u
root="$(cd "$(dirname "$0")/.." && pwd)"
summary="$root/tools/missing_code_vcs_summary.txt"
folders=(
  "02_sequential_logic/sequence_101_moore"
  "05_fsm_and_protocols/state_machine_regout"
  "07_arithmetic_and_datapath/dot_product3"
  "07_arithmetic_and_datapath/code_debug"
  "07_arithmetic_and_datapath/serial_adder"
  "07_arithmetic_and_datapath/bit_serial_add_sub"
  "07_arithmetic_and_datapath/serial_comparator"
  "07_arithmetic_and_datapath/matvec_2x2"
  "07_arithmetic_and_datapath/sum_average"
  "07_arithmetic_and_datapath/max_min_index"
  "05_fsm_and_protocols/vending_machine"
  "07_arithmetic_and_datapath/serial_subtractor"
  "07_arithmetic_and_datapath/modular_serial_adder"
  "07_arithmetic_and_datapath/serial_adder_8_sync_reset"
)
failed=0
: > "$summary"
tmp_log="$(mktemp)"
trap 'rm -f "$tmp_log"' EXIT
for folder in "${folders[@]}"; do
  printf '== %s ==\n' "$folder"
  if (cd "$root/$folder" && make) >"$tmp_log" 2>&1; then
    result=PASS
  else
    result=FAIL
    failed=1
    cat "$tmp_log"
  fi
  if [ "$result" = PASS ]; then
    grep -q '^PASS:' "$tmp_log" || { result=FAIL; failed=1; cat "$tmp_log"; }
  fi
  (cd "$root/$folder" && make clean && rm -f ucli.key) || { result=CLEAN_FAIL; failed=1; }
  printf '%s %s\n' "$result" "$folder" | tee -a "$summary"
done
printf '\nSummary: %s\n' "$summary"
exit "$failed"
