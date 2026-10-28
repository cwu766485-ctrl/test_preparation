#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
summary="$root/tools/vcs_summary.tsv"
failures="$root/tools/vcs_failures"
tmp_log="$(mktemp)"
trap 'rm -f "$tmp_log"' EXIT

mkdir -p "$failures"
printf 'directory\ttop\tstatus\twarnings\n' > "$summary"

total=0
passed=0
failed=0
while IFS= read -r makefile; do
    directory="$(dirname "$makefile")"
    relative="${directory#"$root"/}"
    tops="$(sed -n 's/^TOPS := //p' "$makefile")"
    for top in $tops; do
        total=$((total + 1))
        make -C "$directory" "test_$top" >"$tmp_log" 2>&1
        status=$?
        warnings="$(grep -c '^Warning' "$tmp_log" || true)"
        if [ "$status" -eq 0 ] && grep -q '^PASS:' "$tmp_log"; then
            result=PASS
            passed=$((passed + 1))
        else
            result=FAIL
            failed=$((failed + 1))
            safe_name="${relative//\//__}__${top}.log"
            cp "$tmp_log" "$failures/$safe_name"
        fi
        printf '%s\t%s\t%s\t%s\n' "$relative" "$top" "$result" "$warnings" >> "$summary"
        printf '[%d] %s/%s %s (VCS warnings: %s)\n' "$total" "$relative" "$top" "$result" "$warnings"
    done
    if ! make -C "$directory" clean >/dev/null 2>&1; then
        failed=$((failed + 1))
        printf 'CLEAN_FAIL\t%s\tclean\t0\n' "$relative" >> "$summary"
        printf 'Cleanup failed: %s\n' "$relative" >&2
    fi
done < <(find "$root" -name Makefile -not -path '*/build/*' -type f \
    -exec grep -l '^TOPS :=' {} \; | sort)

printf 'VCS smoke summary: %d total, %d passed, %d failed\n' "$total" "$passed" "$failed"
printf 'Summary file: %s\n' "$summary"
if [ "$failed" -ne 0 ]; then
    printf 'Failure logs: %s\n' "$failures"
    exit 1
fi
