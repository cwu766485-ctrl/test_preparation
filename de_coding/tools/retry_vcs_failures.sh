#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
summary="$root/tools/vcs_summary.tsv"
failures="$root/tools/vcs_failures"
tmp_log="$(mktemp)"
trap 'rm -f "$tmp_log"' EXIT

if [ ! -f "$summary" ]; then
    printf 'Missing prior summary: %s\n' "$summary" >&2
    exit 2
fi

failed_targets="$(awk -F '\t' 'NR > 1 && $3 == "FAIL" { print $1 "\t" $2 }' "$summary")"
if [ -z "$failed_targets" ]; then
    printf 'No failed targets to retry.\n'
    exit 0
fi

retry_total=0
retry_passed=0
retry_failed=0
while IFS=$'\t' read -r relative top; do
    [ -n "$top" ] || continue
    retry_total=$((retry_total + 1))
    directory="$root/$relative"
    make -C "$directory" "test_$top" >"$tmp_log" 2>&1
    status=$?
    warnings="$(grep -c '^Warning' "$tmp_log" || true)"
    safe_name="${relative//\//__}__${top}.log"
    if [ "$status" -eq 0 ] && grep -q '^PASS:' "$tmp_log"; then
        result=PASS
        retry_passed=$((retry_passed + 1))
        if [ -f "$failures/$safe_name" ]; then
            rm -f "$failures/$safe_name"
        fi
    else
        result=FAIL
        retry_failed=$((retry_failed + 1))
        cp "$tmp_log" "$failures/$safe_name"
    fi

    awk -F '\t' -v OFS='\t' -v dir="$relative" -v target="$top" \
        -v result="$result" -v warnings="$warnings" \
        'NR == 1 { print; next } $1 == dir && $2 == target { $3=result; $4=warnings } { print }' \
        "$summary" > "$summary.tmp"
    mv "$summary.tmp" "$summary"
    printf '[retry %d] %s/%s %s (VCS warnings: %s)\n' "$retry_total" "$relative" "$top" "$result" "$warnings"
    make -C "$directory" clean >/dev/null 2>&1 || true
done <<< "$failed_targets"

total="$(awk -F '\t' 'NR > 1 { n++ } END { print n+0 }' "$summary")"
passed="$(awk -F '\t' 'NR > 1 && $3 == "PASS" { n++ } END { print n+0 }' "$summary")"
failed="$(awk -F '\t' 'NR > 1 && $3 == "FAIL" { n++ } END { print n+0 }' "$summary")"
printf 'Final VCS smoke summary: %d total, %d passed, %d failed. Retried %d (%d passed, %d failed).\n' \
    "$total" "$passed" "$failed" "$retry_total" "$retry_passed" "$retry_failed"
printf 'Summary file: %s\n' "$summary"
if [ "$failed" -ne 0 ]; then
    printf 'Failure logs: %s\n' "$failures"
    exit 1
fi
