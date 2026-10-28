#!/usr/bin/env bash
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass_count=0
fail_count=0
no_tb_count=0
declare -A seen_dirs=()

while IFS= read -r -d '' sv_file; do
    dir="$(dirname "$sv_file")"
    case "$dir/" in
        */Test2/*|*/adders_uvm/*|*/secretcode/*) continue ;;
    esac
    [[ "$sv_file" == "$dir/"* ]] || continue
    [[ -n "${seen_dirs[$dir]:-}" ]] && continue
    seen_dirs[$dir]=1

    declare -a rtl_files=()
    declare -a tb_files=()
    while IFS= read -r -d '' file; do
        name="$(basename "$file")"
        if [[ "$name" =~ ^tb.*\.(v|sv)$ || "$name" =~ _tb.*\.(v|sv)$ ]]; then
            tb_files+=("$file")
        elif [[ "$file" == *.sv ]]; then
            rtl_files+=("$file")
        elif [[ ! -f "${file%.v}.sv" ]]; then
            rtl_files+=("$file")
        fi
    done < <(find "$dir" -maxdepth 1 -type f \( -name '*.v' -o -name '*.sv' \) -print0 | sort -z)

    case "$dir" in
        */03_clock_domain_crossing/pulse_sync)
            rtl_files+=("$repo_root/03_clock_domain_crossing/multi_bit_synchronizer/multi_bit_synchronizer.sv")
            ;;
        */03_clock_domain_crossing/interrupt_cdc)
            rtl_files+=("$repo_root/03_clock_domain_crossing/pulse_sync/pulse_handshake.sv"
                        "$repo_root/03_clock_domain_crossing/multi_bit_synchronizer/multi_bit_synchronizer.sv")
            ;;
    esac

    if [[ ${#tb_files[@]} -eq 0 ]]; then
        printf 'FAIL %s: no sibling testbench for SystemVerilog source\n' "${dir#"$repo_root/"}"
        fail_count=$((fail_count + 1))
        no_tb_count=$((no_tb_count + 1))
        continue
    fi

    for tb in "${tb_files[@]}"; do
        top="$(awk '/^[[:space:]]*module[[:space:]]+/ { line=$0; sub(/^[[:space:]]*module[[:space:]]+/, "", line); sub(/[[:space:]#;(].*$/, "", line); print line; exit }' "$tb")"
        label="${tb#"$repo_root/"}"
        if [[ -z "$top" ]]; then
            printf 'FAIL %s: cannot find testbench module declaration\n' "$label"
            fail_count=$((fail_count + 1))
            continue
        fi

        work_dir="$(mktemp -d)" || exit 2
        for file in "${rtl_files[@]}" "$tb"; do cp "$file" "$work_dir/"; done
        for data_file in "$dir"/*.txt; do [[ -f "$data_file" ]] && cp "$data_file" "$work_dir/"; done

        if ! (
            cd "$work_dir" || exit 2
            shopt -s nullglob
            sources=(./*.v ./*.sv)
            pli_args=()
            if grep -q '\$fsdb' "$tb"; then
                pli_args=(-P /opt/Synopsys/verdi/V-2023.12-SP2/share/PLI/VCS/LINUX64/novas.tab /opt/Synopsys/verdi/V-2023.12-SP2/share/PLI/VCS/LINUX64/pli.a)
            fi
            vcs -full64 -sverilog -debug -timescale=1ns/1ps +define+VCS -top "$top" "${pli_args[@]}" -o simv "${sources[@]}" >compile.log 2>&1
        ); then
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

        if grep -Eiq '(^|[^[:alpha:]_])FAIL([^[:alpha:]_]|$)|(^|[^[:alpha:]_])ERROR([^[:alpha:]_]|$)|UVM_(ERROR|FATAL)|errors[^0-9]*[1-9][0-9]*|[1-9][0-9]*[^0-9]*errors' "$work_dir/sim.log"; then
            printf 'FAIL %s: testbench reported an error\n' "$label"
            grep -Ei 'FAIL|ERROR|UVM_(ERROR|FATAL)|errors[^0-9]*[1-9][0-9]*|[1-9][0-9]*[^0-9]*errors' "$work_dir/sim.log" | tail -n 20
            fail_count=$((fail_count + 1))
        else
            printf 'PASS %s\n' "$label"
            pass_count=$((pass_count + 1))
        fi
        rm -rf "$work_dir"
    done
done < <(find "$repo_root" -type f -name '*.sv' -print0 | sort -z)

printf 'SUMMARY: %d PASS, %d FAIL (%d directories had no testbench)\n' "$pass_count" "$fail_count" "$no_tb_count"
[[ "$fail_count" -eq 0 ]]
