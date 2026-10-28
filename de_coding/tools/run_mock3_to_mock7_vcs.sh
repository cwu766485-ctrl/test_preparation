#!/usr/bin/env bash
set -u

overall_status=0
for dir in \
  "07_arithmetic_and_datapath/matrix_mul_2x2_seq" \
  "07_arithmetic_and_datapath/multipliers/seq_multiplier8" \
  "05_fsm_and_protocols/ped_traffic_ctrl" \
  "06_advanced_topics_and_systems/arbiter/rr_arbiter4_hold" \
  "06_advanced_topics_and_systems/packet_xor_check"; do
  printf "\n===== %s =====\n" "$dir"
  if (cd "$dir" && make test); then
    test_status=0
  else
    test_status=$?
  fi

  if (cd "$dir" && make clean); then
    clean_status=0
  else
    clean_status=$?
  fi

  if [ "$test_status" -ne 0 ]; then
    printf "FAIL: %s (status %s)\n" "$dir" "$test_status"
    overall_status=1
  fi
  if [ "$clean_status" -ne 0 ]; then
    printf "CLEAN FAIL: %s (status %s)\n" "$dir" "$clean_status"
    overall_status=1
  fi
done

exit "$overall_status"