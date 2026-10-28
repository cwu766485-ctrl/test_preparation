#!/usr/bin/env bash
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$repo_root/Test2"
pass_count=0
expected_bug_count=0
fail_count=0

while IFS= read -r -d '' tb; do
    test_dir="$(dirname "$tb")"
    top="$(awk '/^[[:space:]]*module[[:space:]]+/ { line=$0; sub(/^[[:space:]]*module[[:space:]]+/, "", line); sub(/[[:space:]#;(].*$/, "", line); print line; exit }' "$tb")"
    label="${tb#"$repo_root/"}"
    if [[ -z "$top" ]]; then
        printf 'FAIL %s: cannot find testbench module declaration\n' "$label"
        fail_count=$((fail_count + 1))
        continue
    fi

    work_dir="$(mktemp -d)" || exit 2
    cp "$test_dir"/*.v "$work_dir/"
    for data_file in "$test_dir"/*.txt; do
        [[ -f "$data_file" ]] && cp "$data_file" "$work_dir/"
    done

    if ! (cd "$work_dir" && vcs -full64 -sverilog -debug -timescale=1ns/1ps +define+VCS -top "$top" -o simv ./*.v >compile.log 2>&1); then
        printf 'FAIL %s: VCS compile failed\n' "$label"
        sed -n '/Error-/,$p' "$work_dir/compile.log" | tail -n 40
        rm -rf "$work_dir"
        fail_count=$((fail_count + 1))
        continue
    fi

    if ! (cd "$work_dir" && ./simv >sim.log 2>&1); then
        printf 'FAIL %s: simulator returned nonzero\n' "$label"
        tail -n 40 "$work_dir/sim.log"
        rm -rf "$work_dir"
        fail_count=$((fail_count + 1))
        continue
    fi

    if grep -Eiq 'FAIL|(^|[^[:alpha:]_])ERROR([^[:alpha:]_]|$)|errors[^0-9]*[1-9][0-9]*|[1-9][0-9]*[^0-9]*errors' "$work_dir/sim.log"; then
        if [[ "$label" == *"/16_代码改错/"* ]]; then
            printf 'EXPECTED_FAIL_DETECTED %s\n' "$label"
            expected_bug_count=$((expected_bug_count + 1))
        else
            printf 'FAIL %s: testbench reported an error\n' "$label"
            grep -Ei 'FAIL|ERROR|errors[^0-9]*[1-9][0-9]*|[1-9][^0-9]*errors' "$work_dir/sim.log" | tail -n 20
            fail_count=$((fail_count + 1))
        fi
    elif [[ "$label" == *"/16_代码改错/"* ]]; then
        printf 'FAIL %s: intentional bug was not detected by its testbench\n' "$label"
        fail_count=$((fail_count + 1))
    else
        printf 'PASS %s\n' "$label"
        pass_count=$((pass_count + 1))
    fi
    rm -rf "$work_dir"
done < <(find "$test_root" -type f -iname '*tb*.v' -print0 | sort -z)

printf 'SUMMARY: %d PASS, %d expected bug detections, %d FAIL\n' "$pass_count" "$expected_bug_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]
