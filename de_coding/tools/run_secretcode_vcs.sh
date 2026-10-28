#!/usr/bin/env bash
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
secret_root="$repo_root/07_arithmetic_and_datapath/secretcode"
status=0

run_secretcode_case() {
    local label="$1" source_dir="$2" design="$3" testbench="$4" testbench_dir="${5:-$2}" work_dir
    local -a filelist_args=()
    work_dir="$(mktemp -d)" || return 2
    mkdir -p "$work_dir/rtl" "$work_dir/Library"
    cp "$source_dir/$design" "$testbench_dir/$testbench" "$work_dir/rtl/"
    if [[ -f "$source_dir/secretcode.sdf" ]]; then cp "$source_dir/secretcode.sdf" "$work_dir/rtl/"; fi
    if [[ "$design" == Syn_secretcode.v ]]; then
        cp "$source_dir/library.f" "$work_dir/rtl/"
        ln -s "$secret_root/Library/gf22nsdvlogl20hdl116a.v" "$work_dir/Library/"
        ln -s "$secret_root/Library/gf22nsdvlogl20hdl116a_updated.v" "$work_dir/Library/"
        ln -s "$secret_root/Library/atpg_primitives.v" "$work_dir/Library/"
        ln -s "$secret_root/Library/rtl_primitives.v" "$work_dir/Library/"
        ln -s "$secret_root/Library/std_primitives.v" "$work_dir/Library/"
        filelist_args=(-f library.f)
    fi

    if ! (cd "$work_dir/rtl" && vcs -full64 -v2005 -debug -timescale=1ns/1ps -top secretcode_tb \
          "${filelist_args[@]}" "$design" "$testbench" -o simv >compile.log 2>&1); then
        printf 'FAIL %s: VCS compile failed\n' "$label"
        sed -n '/Error-/,$p' "$work_dir/rtl/compile.log" | tail -n 40
        rm -rf "$work_dir"
        return 1
    fi
    if ! (cd "$work_dir/rtl" && ./simv >sim.log 2>&1); then
        printf 'FAIL %s: simulation returned nonzero\n' "$label"
        tail -n 40 "$work_dir/rtl/sim.log"
        rm -rf "$work_dir"
        return 1
    fi
    if grep -Eiq 'FAIL|(^|[^[:alpha:]_])ERROR([^[:alpha:]_]|$)|errors[^0-9]*[1-9][0-9]*' "$work_dir/rtl/sim.log"; then
        printf 'FAIL %s: testbench reported an error\n' "$label"
        grep -Ei 'FAIL|ERROR|errors[^0-9]*[1-9][0-9]*' "$work_dir/rtl/sim.log" | tail -n 20
        rm -rf "$work_dir"
        return 1
    fi
    printf 'PASS %s\n' "$label"
    rm -rf "$work_dir"
    return 0
}

run_secretcode_case behavioral "$secret_root/Behavioral" secretcode.v secretcode_tb.v || status=1
run_secretcode_case rtl_behavioral "$secret_root/rtl" secretcode.v secretcode_tb.v "$secret_root/Behavioral" || status=1
run_secretcode_case synthesized "$secret_root/rtl" Syn_secretcode.v secretcode_tb.v || status=1

run_fulladder_case() {
    local testbench="$1" label="$2" work_dir
    work_dir="$(mktemp -d)" || return 2
    mkdir -p "$work_dir/rtl" "$work_dir/Library"
    cp "$secret_root/rtl/Syn_FullAdder.v" "$secret_root/rtl/Syn_FullAdder.sdf" \
       "$secret_root/rtl/library.f" "$secret_root/rtl/$testbench" "$work_dir/rtl/"
    ln -s "$secret_root/Library/gf22nsdvlogl20hdl116a.v" "$work_dir/Library/"
    ln -s "$secret_root/Library/gf22nsdvlogl20hdl116a_updated.v" "$work_dir/Library/"
    ln -s "$secret_root/Library/atpg_primitives.v" "$work_dir/Library/"
    ln -s "$secret_root/Library/rtl_primitives.v" "$work_dir/Library/"
    ln -s "$secret_root/Library/std_primitives.v" "$work_dir/Library/"

    if ! (cd "$work_dir/rtl" && vcs -full64 -v2005 -debug -timescale=1ns/1ps \
          -top FullAdder_tb -f library.f Syn_FullAdder.v "$testbench" -o simv >compile.log 2>&1); then
        printf 'FAIL %s: VCS compile failed\n' "$label"
        sed -n '/Error-/,$p' "$work_dir/rtl/compile.log" | tail -n 40
        rm -rf "$work_dir"
        return 1
    fi
    if ! (cd "$work_dir/rtl" && ./simv >sim.log 2>&1); then
        printf 'FAIL %s: simulation returned nonzero\n' "$label"
        tail -n 40 "$work_dir/rtl/sim.log"
        rm -rf "$work_dir"
        return 1
    fi
    if grep -Eiq 'FAIL|(^|[^[:alpha:]_])ERROR([^[:alpha:]_]|$)|errors[^0-9]*[1-9][0-9]*' "$work_dir/rtl/sim.log"; then
        printf 'FAIL %s: testbench reported an error\n' "$label"
        grep -Ei 'FAIL|ERROR|errors[^0-9]*[1-9][0-9]*' "$work_dir/rtl/sim.log" | tail -n 20
        rm -rf "$work_dir"
        return 1
    fi
    if [[ "$testbench" == FullAdder_tb_auto.v ]] && ! grep -q 'Functional errors: 0' "$work_dir/rtl/sim.log"; then
        printf 'FAIL %s: missing zero-error functional summary\n' "$label"
        tail -n 20 "$work_dir/rtl/sim.log"
        rm -rf "$work_dir"
        return 1
    fi
    printf 'PASS %s\n' "$label"
    rm -rf "$work_dir"
    return 0
}

run_fulladder_case FullAdder_tb.v fulladder_transition_tb || status=1
run_fulladder_case FullAdder_tb_auto.v fulladder_selfcheck_tb || status=1

run_sequence_compile() {
    local work_dir
    work_dir="$(mktemp -d)" || return 2
    mkdir -p "$work_dir/rtl" "$work_dir/Library"
    cp "$secret_root/rtl/library.f" "$secret_root/Synthesis/netlist/Syn_sequence.v" "$work_dir/rtl/"
    ln -s "$secret_root/Library/gf22nsdvlogl20hdl116a.v" "$work_dir/Library/"
    ln -s "$secret_root/Library/gf22nsdvlogl20hdl116a_updated.v" "$work_dir/Library/"
    ln -s "$secret_root/Library/atpg_primitives.v" "$work_dir/Library/"
    ln -s "$secret_root/Library/rtl_primitives.v" "$work_dir/Library/"
    ln -s "$secret_root/Library/std_primitives.v" "$work_dir/Library/"
    if ! (cd "$work_dir/rtl" && vcs -full64 -v2005 -debug -timescale=1ns/1ps \
          -top sequence -f library.f Syn_sequence.v -o simv >compile.log 2>&1); then
        printf 'FAIL synthesized sequence: VCS elaboration failed\n'
        sed -n '/Error-/,$p' "$work_dir/rtl/compile.log" | tail -n 40
        rm -rf "$work_dir"
        return 1
    fi
    printf 'PASS synthesized sequence compile/elaboration (no TB present)\n'
    rm -rf "$work_dir"
    return 0
}

run_sequence_compile || status=1
exit "$status"
